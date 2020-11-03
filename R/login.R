# Implement the OAuth2.0 device grant flow
# https://tools.ietf.org/html/rfc6749#section-1.3.1
# https://help.salesforce.com/articleView?id=remoteaccess_oauth_device_flow.htm&type=5
#
# Returns a CCM access token for use in
# authorizing subsequent CCM requests


login <- function() {
  aurhtorizationBody <- list(
    response_type = 'device_code',
    client_id = Sys.getenv('SALESFORCE_CLIENT_ID')
  )
  res <- POST(
    url = 'https://mohcontacttracing.my.salesforce.com/services/oauth2/token',
    body = aurhtorizationBody,
    encode = 'form'
  )
  response <- content(res)
  cat(
    paste(
      'Visit ', response$verification_uri, '?user_code=', response$user_code, '\n',
      sep = ''
    )
  )
  # Start polling for the access token
  tokenResponse <- data.frame()
  tokenBody <- list(
    grant_type = 'device',
    client_id = Sys.getenv('SALESFORCE_CLIENT_ID'),
    code = response$device_code
  )
  while(!('access_token' %in% names(tokenResponse))) {
    # wait and try again
    Sys.sleep(7)
    resp <- POST(
      url = 'https://mohcontacttracing.my.salesforce.com/services/oauth2/token',
      body = tokenBody,
      encode = 'form'
    )
    tokenResponse <- content(resp)
  }
  cat('Login successful!\n')
  # Save the access token in the OS key ring
  key_set_with_value(
    'CCM',
    'AccessToken',
    password = tokenResponse$access_token
  )
}
