# Create a file to hold the access token
createCache <- function(path = '.access') {
  file.create(path, showWarnings = FALSE)
  if (!file.exists(path)) {
    stop("Failed to create local cache ('", path, "')", call. = FALSE))
  }
  # Protect the cache as much as possible
  Sys.chmod(path, '0600')
  # Return
  TRUE
}

# Save the token to the specified file
cacheToken <- function(token, filePath) {
  if (is.null(filePath)) {
    return()
  }
  tokens <- loadTokenCache(filePath)
  tokens[[token$hash]] <- token
  saveRDS(tokens, filePath)
}

# Load token from the specified file
loadTokenCache <- function(filePath) {
  if (!file.exists(filePath) || file_size(filePath) == 0) {
    list()
  } else {
    readRDS(filePath)
  }
}

# Clean out any cached tokens
removeCachedToken <- function(token) {
  if (is.null(token$cache_path)) {
    return()
  }
  tokens <- loadTokenCache(token$cache_path)
  tokens[[token$hash()]] <- NULL
  saveRDS(tokens, token$cache_path)
}
