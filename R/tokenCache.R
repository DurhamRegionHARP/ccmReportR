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
  tokens[[token$hash]] <- NULL
  saveRDS(tokens, token$cache_path)
}
