#' @export
launchEditor <- function() {
  appDir <- system.file("hiveeditor", package = "HiveEditor")
  if (appDir == "") {
    stop("Could not find Hive editor directory. Try re-installing `HiveEditor`.", call. = FALSE)
  }

  shiny::runApp(appDir, display.mode = "normal", launch.browser = TRUE)
}
