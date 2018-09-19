## DEPENDENCIES --------------------------------------------------------------------------------------------------------
library(DBI)
library(pool)
library(tidyverse)
library(formattable)
library(DT)
library(lubridate)
library(shinyAce)
library(shinyalert)

## CREATE CONNECTION TO dsna BY DSN ------------------------------------------------------------------------------------
pool <- dbPool(odbc::odbc(), dsn = "HP1-64bit", Port = 10000)

onStop(function() {
  poolClose(pool)
})

## SERVER --------------------------------------------------------------------------------------------------------------
server <- function(input, output, session) {

  tryCatch({
    nrow(dbGetQuery(pool, "show tables")) >= 1
    shinyalert("You're connected!",
               "This app is connected to dsna.",
               type = "success",
               closeOnClickOutside = TRUE)
  },
  error = function(e) {
    shinyalert("Oops!",
               "This app is disconnected to dsna. Please refresh it",
               type = "error",
               closeOnClickOutside = TRUE)
  })

  ## HIVE EDITOR -------------------------------------------------------------------------------------------------------
  # Store editor input
  sql_script <- eventReactive(input$run_sql, {
    input$code
  })

  # Initialize blank table for recent queries
  reactive_values <- reactiveValues()

  reactive_values$queries_table <- tibble(Time = character(0), Query = character(0))

  # Execute sql query and update recent queries table
  observeEvent(input$run_sql, {
    # Query result
    output$sql_result <- renderDT(
      withProgress(message = 'Retrieving data', {
        tryCatch({
          datatable(dbGetQuery(pool, sql_script()),
                    extensions = c("Buttons", "Scroller"),
                    options = list(dom = 'Bfrtip',
                                   buttons = "csv",
                                   deferRender = TRUE,
                                   scroller = TRUE,
                                   scrollY = 560,
                                   scrollX = TRUE))
        },
        error = function(e) {
          shinyalert("Oops!", conditionMessage(e), type = "error", closeOnClickOutside = TRUE)
        })
      }),
      server = FALSE
    )

    # Update recent queries table
    reactive_values$queries_table <- add_row(reactive_values$queries_table,
                                             Time = format(Sys.time(), "%Y-%m-%d %r"),
                                             Query = sql_script())

    output$recent_queries <- renderDT(
      datatable(reactive_values$queries_table, options = list(dom = 't')) %>%
        formatStyle("Query", color = "red")
    )
  })

  ## DOWNLOAD SQL SCRIPT -----------------------------------------------------------------------------------------------
  output$downloadData <- downloadHandler(
    filename = function() {
      "Hive.sql"
    },
    content = function(file) {
      write_file(sql_script(), file)
    }
  )

  ## EDITOR THEME ------------------------------------------------------------------------------------------------------
  observe({
    updateAceEditor(session,
                    "code",
                    mode = "sql",
                    theme = input$editor_theme)
  })

  ## CHECK dsna CONNECTION ---------------------------------------------------------------------------------------------
  observeEvent(input$check_connection, {
    tryCatch({
      nrow(dbGetQuery(pool, "show tables")) >= 1
      shinyalert("You're connected!",
                 "This app is connected to dsna.",
                 type = "success",
                 closeOnClickOutside = TRUE)
    },
    error = function(e) {
      shinyalert("Oops!",
                 "This app is disconnected to dsna. Please refresh it",
                 type = "error",
                 closeOnClickOutside = TRUE)
    })
  })
}
