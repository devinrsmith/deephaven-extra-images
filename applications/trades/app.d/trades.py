import threading
import json
import websocket

from deephaven import agg, dtypes, DynamicTableWriter
from deephaven.time import to_datetime
from deephaven.table import Table
from deephaven.execution_context import make_user_exec_ctx

ctx = make_user_exec_ctx()
matches_table = None
matches_stats = None

def table_writer(columns):
    writer = DynamicTableWriter(columns)

    def convert(value, column_type):
        if column_type == dtypes.int_:
            return int(value)
        if column_type == dtypes.string:
            return str(value)
        if column_type == dtypes.float_:
            return float(value)
        if column_type == dtypes.DateTime:
            return to_datetime(f"{value[0:-1]} UTC")
        return value

    def map_row(data, columns):
        row = []
        for column_name, column_type in columns.items():
            value = convert(data[column_name], column_type)
            row.append(value)
        return row

    def write_row(s):
        row = map_row(json.loads(s), columns)
        writer.write_row(*row)

    return writer.table, write_row


def matches():
    return table_writer(
        {
            "product_id": dtypes.string,
            "time": dtypes.DateTime,
            "side": dtypes.string,
            "size": dtypes.float_,
            "price": dtypes.float_,
            "type": dtypes.string,
            "trade_id": dtypes.int_,
            "maker_order_id": dtypes.string,
            "taker_order_id": dtypes.string,
            "sequence": dtypes.int_,
        }
    )


def subscribe_matches(ws, product_ids=["BTC-USD", "ETH-USD"]):
    ws.send(
        json.dumps(
            {"type": "subscribe", "product_ids": product_ids, "channels": ["matches"]}
        )
    )
    ws.recv()


def run_matches_loop(consumer):
    ws = websocket.create_connection("wss://ws-feed.exchange.coinbase.com")
    subscribe_matches(ws)
    while True:
        consumer(ws.recv())

class thread(threading.Thread):
    def __init__(self):
        threading.Thread.__init__(self)
        self.semaphore = threading.Semaphore(value=0)

    def run(self):
        global matches_table
        global matches_stats
        with ctx:

            # Initialize the matches table
            matches_table, matches_writer = matches()

            # Create a simple aggregation
            matches_stats = matches_table.update_view(["volume=price*size"]).agg_by(
                [
                    agg.count_("count"),
                    agg.sum_("volume"),
                    agg.last(["time", "last_price=price", "last_size=size"]),
                    agg.weighted_avg("size", "avg_price=price"),
                ],
                ["product_id"],
            )

            # Show the most recent rows first
            matches_table = matches_table.reverse()

        self.semaphore.release(n=1)

        # Hook up the data source
        run_matches_loop(matches_writer)

coinbase_thread = thread()
coinbase_thread.start()
coinbase_thread.semaphore.acquire()
