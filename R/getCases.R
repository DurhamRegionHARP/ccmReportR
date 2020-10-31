# Execute a SOQL query against the Case object
# The Case object maps to Investigations on the client-side

getCases <- function(query, access_token) {
  # Define some constants
  resource_uri <- 'https://mohcontacttracing.my.salesforce.com/services/data/v49.0/query/?q='
  # Validate the query
  if (is.null(query)) {
    cat('gotCases: Expected a query to execute...Please try again!\n')
  } else {
    # Post the query to Salesforce
    resp <- GET(
      url = paste(resource_uri, query, sep=''),
      add_headers(Authorization = paste('Bearer', access_token))
    )
    # Parse the results
    data <- fromJSON(content(resp, 'text'))
    if ('MALFORMED_QUERY' %in% names(data)) {
      cat('Your query returned an error\n')
    } else {
      data
    }
  }
}
