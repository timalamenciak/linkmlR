#' Configure linkmlr
#'
#' @param python Path to python executable (optional).
#' @param condaenv Name of conda env to use (optional).
#' @param virtualenv Name/path of virtualenv to use (optional).
#' @return A list with the active configuration (invisibly).
#' @export
linkmlr_config <- function(python = NULL, condaenv = NULL, virtualenv = NULL) {
  opts <- list(
    linkmlr.python = python,
    linkmlr.condaenv = condaenv,
    linkmlr.virtualenv = virtualenv
  )
  do.call(options, opts)
  invisible(opts)
}

#' Select python / env for reticulate
#'
#' Call once per session, early.
#'
#' @export
linkmlr_use_python <- function() {
  python <- getOption("linkmlr.python", Sys.getenv("LINKMLR_PYTHON", ""))
  condaenv <- getOption("linkmlr.condaenv", Sys.getenv("LINKMLR_CONDAENV", ""))
  virtualenv <- getOption("linkmlr.virtualenv", Sys.getenv("LINKMLR_VIRTUALENV", ""))

  if (nzchar(python)) {
    reticulate::use_python(python, required = TRUE)
    return(invisible(list(mode = "python", value = python)))
  }
  if (nzchar(condaenv)) {
    reticulate::use_condaenv(condaenv, required = TRUE)
    return(invisible(list(mode = "condaenv", value = condaenv)))
  }
  if (nzchar(virtualenv)) {
    reticulate::use_virtualenv(virtualenv, required = TRUE)
    return(invisible(list(mode = "virtualenv", value = virtualenv)))
  }

  # Default: do nothing; reticulate will pick something.
  invisible(list(mode = "auto", value = NULL))
}

#' Install Python dependencies for LinkML
#'
#' @param method "conda" or "virtualenv" or "pip" (passed to reticulate).
#' @param envname Environment name (if creating/managing one).
#' @param packages Python packages to install.
#' @export
linkmlr_install_python_deps <- function(
    method = c("conda", "virtualenv", "pip"),
    envname = "linkmlr",
    packages = c("linkml", "linkml-runtime")
) {
  method <- match.arg(method)

  if (method == "conda") {
    reticulate::conda_create(envname)
    reticulate::conda_install(envname, packages = packages, pip = TRUE)
    linkmlr_config(condaenv = envname)
  } else if (method == "virtualenv") {
    reticulate::virtualenv_create(envname)
    reticulate::virtualenv_install(envname, packages = packages)
    linkmlr_config(virtualenv = envname)
  } else {
    reticulate::py_install(packages, pip = TRUE)
  }

  invisible(TRUE)
}
