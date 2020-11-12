#' Obtain an access token to authroize requests
#'
#' This function implements the OAuth2.0 device grant flow
#' see <https://tools.ietf.org/html/rfc6749#section-1.3.1>
#' and <https://help.salesforce.com/articleView?id=remoteaccess_oauth_device_flow.htm&type=5>
#' for more information. The token is stored in the OS keyring.
#'
#' @return CCM access token for use in authorizing subsequent requests.
#' @export

login <- function() {
  aurhtorizationBody <- list(
    response_type = 'device_code',
    client_id = '3MVG9l2zHsylwlpRMdxSJfjHJuwYtJOXTCdPQF2LEAB7jbdyKDnjkFGrE4RW.8ZBwQQUp5RdOQKoKSiQIrOZK'
  )
  res <- httr::POST(
    url = 'https://mohcontacttracing.my.salesforce.com/services/oauth2/token',
    body = aurhtorizationBody,
    encode = 'form'
  )
  response <- jsonlite::fromJSON(httr::content(res, 'text'))
  cat(
    paste(
      'Open a browser and login at: ',
      response$verification_uri,
      '?user_code=',
      response$user_code,
      '\n',
      sep = ''
    )
  )
  # Start polling for the access token
  tokenResponse <- data.frame()
  tokenBody <- list(
    grant_type = 'device',
    client_id = '3MVG9l2zHsylwlpRMdxSJfjHJuwYtJOXTCdPQF2LEAB7jbdyKDnjkFGrE4RW.8ZBwQQUp5RdOQKoKSiQIrOZK',
    code = response$device_code
  )
  while(!('access_token' %in% names(tokenResponse))) {
    # wait and try again
    Sys.sleep(7)
    resp <- httr::POST(
      url = 'https://mohcontacttracing.my.salesforce.com/services/oauth2/token',
      body = tokenBody,
      encode = 'form'
    )
    tokenResponse <- httr::content(resp)
  }
  cat('Login successful!\n')
  # Save the access token in the OS key ring
  keyring::key_set_with_value(
    'CCM',
    'AccessToken',
    password = tokenResponse$access_token
  )
}
