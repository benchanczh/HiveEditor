## DEPENDENCIES --------------------------------------------------------------------------------------------------------
library(shiny)
library(shinydashboard)
library(visNetwork)
library(highcharter)
library(DT)
library(shinyAce)
library(shinyalert)

## SIDEBAR -------------------------------------------------------------------------------------------------------------
sidebar <- dashboardSidebar(
  sidebarMenu(
    menuItem("Hive", tabName = "hiveql", icon = icon("database")),
    useShinyalert(),
    # Action button to check if the app is connected to dsna
    actionButton("check_connection",
                 "Check dsna connection",
                 icon = icon("wifi"),
                 style = "position: absolute; bottom: 10px")
  )
)


## BODY ----------------------------------------------------------------------------------------------------------------
body <- dashboardBody(
  fluidRow(
    tabItems(
      # Hive editor tab
      tabItem(tabName = "hiveql",
              fluidRow(
                tabBox(
                  width = 9,
                  tabPanel("Hive editor",
                           # Ace editor for users to query dsna data
                           aceEditor(
                             "code",
                             mode = "sql",
                             wordWrap = TRUE,
                             theme = "tomorrow_night_eighties",
                             height = "200px",
                             fontSize = 14,
                             autoComplete = "live"
                           ),
                           actionButton("run_sql",
                                        "Execute",
                                        icon = icon("cogs"),
                                        style = "color: #ffffff; background-color: #D81E05"),
                           downloadButton("downloadData", "Download"))
                ),
                tabBox(
                  width = 3,
                  tabPanel("Editor theme",
                           # Users can change Ace editor's theme
                           selectInput(
                             "editor_theme",
                             "Theme:",
                             choices = getAceThemes(),
                             selected = "tomorrow_night_eighties"))
                ),
                tabBox(
                  width = 12,
                  tabPanel("Result",
                           # Show current query result
                           DTOutput("sql_result")),
                  tabPanel("Recent queries",
                           # Show previous queries
                           DTOutput("recent_queries"))
                )
              )
      )
    ),


    ## ADDITIONAL CSS STYLE --------------------------------------------------------------------------------------------
    tags$head(
      tags$style(
        HTML(
          "/* logo */
          .skin-blue .main-header .logo {
          background-color: #D81E05;
          }

          /* logo when hovered */
          .skin-blue .main-header .logo:hover {
          background-color: #D81E05;
          }

          /* navbar (rest of the header) */
          .skin-blue .main-header .navbar {
          background-color: #D81E05;
          }

          /* toggle button when hovered  */
          .skin-blue .main-header .navbar .sidebar-toggle:hover {
          background-color: #D81E05;
          }

          /* notification when connecting to dsna or retrieving data from dsna  */
          .shiny-notification {
          height: 61.8px;
          width: 200px;
          position: fixed;
          top: calc(50% - 50px);;
          left: 50%;
          }
          "
        )
      )
    )
  )
)


## DASHBOARD PAGE ------------------------------------------------------------------------------------------------------
ui <- dashboardPage(
  dashboardHeader(
    title = "dsna bess network",
    tags$li(class = "dropdown")

  ),
  sidebar,
  body
)
