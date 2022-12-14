group "default" {
    targets = [ "js-plugins", "applications" ]
}

group "release" {
    targets = [ "js-plugins-release", "applications-release" ]
}

group "js-plugins" {
    targets = [
        "matplotlib",
        "plotly"
    ]
}

group "applications" {
    targets = [
        "trades"
    ]
}


group "js-plugins-release" {
    targets = [
        "web-plugin-packager-release",
        "matplotlib-release",
        "plotly-release"
    ]
}

group "applications-release" {
    targets = [
        "trades-release"
    ]
}

# -------------------------------------

variable "REPO_PREFIX" {
    default = ""
}

variable "DEEPHAVEN_TAG" {
    default = "latest"
}

variable "TAG" {
    default = "latest"
}

variable "CACHE_PREFIX" {
    default = "deephaven-extra-images-"
}

# -------------------------------------

target "web-plugin-packager" {
    context = "web-plugin-packager/"
    tags = [
        "${REPO_PREFIX}web-plugin-packager:${TAG}"
    ]
}

# -------------------------------------

target "js-plugins-contexts" {
    context = "js-plugins/"
    contexts = {
        web-plugin-packager = "target:web-plugin-packager"
    }
    args = {
        "DEEPHAVEN_TAG" = "${DEEPHAVEN_TAG}"
    }
}

target "matplotlib" {
    inherits = [ "js-plugins-contexts" ]
    tags = [
        "${REPO_PREFIX}deephaven-matplotlib:${TAG}"
    ]
    args = {
        "NPM_PACKAGES" = "@deephaven/js-plugin-matplotlib"
        "PYTHON_PACKAGES" = "deephaven-plugin-matplotlib"
    }
}

target "plotly" {
    inherits = [ "js-plugins-contexts" ]
    tags = [
        "${REPO_PREFIX}deephaven-plotly:${TAG}"
    ]
    args = {
        "NPM_PACKAGES" = "@deephaven/js-plugin-plotly"
        "PYTHON_PACKAGES" = "deephaven-plugin-plotly"
    }
}

# -------------------------------------

target "trades" {
    context = "applications/trades/"
    tags = [
        "${REPO_PREFIX}deephaven-trades-app:${TAG}"
    ]
}

# -------------------------------------

target "web-plugin-packager-release" {
    inherits = [ "web-plugin-packager" ]
    platforms = [ "linux/amd64", "linux/arm64" ]
    cache-from = [ "type=gha,scope=${CACHE_PREFIX}web-plugin-packager" ]
    cache-to = [ "type=gha,mode=max,scope=${CACHE_PREFIX}web-plugin-packager" ]
}

# -------------------------------------

target "matplotlib-release" {
    inherits = [ "matplotlib" ]
    platforms = [ "linux/amd64", "linux/arm64" ]
    cache-from = [ "type=gha,scope=${CACHE_PREFIX}matplotlib" ]
    cache-to = [ "type=gha,mode=max,scope=${CACHE_PREFIX}matplotlib" ]
}

target "plotly-release" {
    inherits = [ "plotly" ]
    platforms = [ "linux/amd64", "linux/arm64" ]
    cache-from = [ "type=gha,scope=${CACHE_PREFIX}plotly" ]
    cache-to = [ "type=gha,mode=max,scope=${CACHE_PREFIX}plotly" ]
}

# -------------------------------------

target "trades-release" {
    inherits = [ "trades" ]
    platforms = [ "linux/amd64", "linux/arm64" ]
    cache-from = [ "type=gha,scope=${CACHE_PREFIX}trades" ]
    cache-to = [ "type=gha,mode=max,scope=${CACHE_PREFIX}trades" ]
}

# -------------------------------------
