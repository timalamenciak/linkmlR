#' Call the LinkML CLI
#'
#' @param ... Character args, e.g. c("validate", "-s", "schema.yaml", "data.yaml")
#' @return A list with stdout/stderr/status.
#' @export
linkml_cli <- function(...) {
  linkmlr_use_python()
  py <- reticulate::py_config()$python
  args <- c("-m", "linkml", ...)

  out <- system2(py, args = args, stdout = TRUE, stderr = TRUE)
  status <- attr(out, "status") %||% 0L

  list(status = status, output = out)
}

#' Generate artifacts from a LinkML schema using the CLI
#'
#' @param generator A generator name, e.g. "jsonschema" or "python".
#' @param schema Path to schema YAML.
#' @param ... Extra CLI args.
#' @export
linkml_generate <- function(generator, schema, ...) {
  if (!file.exists(schema)) abort("Schema file does not exist: {schema}")
  linkml_cli("generate", generator, normalizePath(schema), ...)
}
