library(move2)
library(shiny)
library(foreach)
library(geosphere)
library(shinycssloaders)
library(sf)

###### Interface #####################

shinyModuleUserInterface <- function(id, label = NULL) {
  ns <- NS(id)
  
  fluidPage(
    titlePanel("Distance to Location over Time"),
    
    sidebarLayout(
      sidebarPanel(width = 3,
                   
                   h4("Tracks"),
                   checkboxGroupInput(ns("animals"), NULL, choices = NULL),
                   fluidRow(
                     column(6, actionButton(ns("select_all_animals"), "Select All", class = "btn-sm")),
                     column(6, actionButton(ns("unselect_animals"), "Unselect All", class = "btn-sm"))   ),
                   
                   h4("Reference Location"),
                   fluidRow(
                     column(6, numericInput(ns("posi_lon"), "Longitude:", value=0, min = -180, max = 180,step=0.00001)),
                     column(6, numericInput(ns("posi_lat"), "Latitude:", value=0, min = -90, max = 90,step=0.00001))  ),
                   
                   hr(),
                   actionButton(ns("apply_btn"), "Apply Changes", class = "btn-primary btn-block"),
                   hr(),
                   
                   h4("Download:"),
                   fluidRow(
                     column(6,downloadButton(ns("save_plot"), "Download plot")),
                     column(6,downloadButton(ns("save_table"), "Save Table(csv)")))
      ),
      
      mainPanel(withSpinner(plotOutput(ns("timeline"), height = "80vh")))
    )
  )
}

########### server ###############

shinyModule <- function(input, output, session, data) {
  ns <- session$ns
  mv <- data
  
  # transfer to WGS84 if needed
  if (!sf::st_is_longlat(mv)) {
    mv <- sf::st_transform(mv, 4326)
  }
  
  trk_col    <- mt_track_id_column(mv)
  all_animals <- unique(as.character(mv[[trk_col]]))
  selected_animals <- reactiveVal(all_animals)
                                  
  #### Select animals in side bar#################
  observe({
    updateCheckboxGroupInput(session = session, inputId = "animals",  choices  = all_animals, selected = all_animals)
  })
  
  #select all individuals
  observeEvent(input$select_all_animals, {
    updateCheckboxGroupInput(session = session, inputId = "animals", selected = all_animals )
  })
  
  #unselect all individuals
  observeEvent(input$unselect_animals, {
    updateCheckboxGroupInput( session = session, inputId = "animals", selected = character(0) )
  })
  
  
  #### Reference coordinates ######### 
  userCorrds <- reactiveValues(posi_lon = 0, posi_lat = 0)
  
  observeEvent(input$apply_btn, {
    userCorrds$posi_lon <- input$posi_lon
    userCorrds$posi_lat <- input$posi_lat
    selected_animals(input$animals)
  })
  
  ## Filter data by selected animals
  mv_sel <- reactive({
    ids <- selected_animals()
    req(length(ids) > 0)
    mv[mv[[trk_col]] %in% ids, ]
  })
  
  
  ## make distance table
  dist_table <- reactive({
    dat <- mv_sel()
    req(nrow(dat) > 0)
    
    # split
    data_split <- split(dat, dat[[trk_col]])
    
    foreach(datai = data_split, .combine = rbind) %do% {
      track_id <- as.character(mt_track_id(datai))
      
      cooi  <- sf::st_coordinates(datai)
      timei <- mt_time(datai)
      disti <- geosphere::distVincentyEllipsoid(
        cooi,
        c(userCorrds$posi_lon, userCorrds$posi_lat)
      )
      
      data.frame(
        track_id = track_id,
        timestamp = timei,
        location_long = cooi[, 1],
        location_lat = cooi[, 2],
        distance_to_location_m = disti
      )
    }
    
  })
  
  ##Names
  namen <- reactive({
    df <- dist_table()
    unique(as.character(df$track_id))
  })
  
  
  ##Colors
  cols <- reactive({grDevices::hcl.colors(length(namen()), palette = "Viridis")  })
  
  ######  Plot ########
  sv_plot <- reactiveVal(NULL)
  output$timeline <- renderPlot({
    
    df <- dist_table()
    req(nrow(df) > 0)
    
    ## time axis
    timestamp_range <- range(df$timestamp)
   
    ## distance range
    dist_range <- range(df$distance_to_location_m, na.rm = TRUE)
    
    ## split by tracks
    df_split <- split(df, df$track_id)
    
    indiv_names <- namen()
    indiv_cols  <- cols()
    
    par(mar = c(12, 4, 6, 2) + 0.1, font.lab = 2 )
    plot(
      x = timestamp_range,
      y = dist_range,
      type = "n",   
      xlim = timestamp_range,
      #ylim = dist_range,
      ylim = c(dist_range[1], dist_range[2] + ( 0.2 * diff(dist_range))),
      xlab = "",
      ylab = "Distance to reference location (m)",
      axes = FALSE  )
    
    abline(h   = pretty(dist_range, n = 6),  col = "grey90",  lty = "dotted"  )
    box()
    axis(2)
    ##+++++++++++++++++++++
    time_breaks <- pretty(df$timestamp, n = 30)
    step_unit <- attr(difftime(time_breaks[2], time_breaks[1]),  "units") 
    
    ## choose format based on unit
    if (step_unit %in% c("secs", "mins", "hours")) {
      time_fmt <- "%Y-%m-%d_%H:%M:%S"
    } else { time_fmt <- "%Y-%m-%d" }
    
    axis( side = 1, at = time_breaks, labels = format(time_breaks, time_fmt), las= 2 )
  
    mtext("time", side = 1, line = 10, font = 2)
    
    title("Distance to reference location over time")
    
    # draw one line per individual
    for (i in seq_along(indiv_names)) {
      dfi <- df_split[[indiv_names[i]]]
      lines(x = dfi$timestamp,y   = dfi$distance_to_location_m, col = indiv_cols[i], lwd = 2) }
    
    legend("topright",legend = indiv_names, col = indiv_cols, lwd = 2, bty= "n")
    
    # store plot
    sv_plot(recordPlot())
  })
  
  
  
  ### save plot ###
  output$save_plot <- downloadHandler(
    filename = function() { paste0("distance_plot_",input$posi_lon, "_", input$posi_lat, ".png" ) },
    content = function(file) {
      png(file, width = 960, height = 480)
      replayPlot(sv_plot())   
      dev.off()
    }
  )
  
  
  ## Save table (CSV) 
  output$save_table <- downloadHandler(
    filename = function() { paste0("distance_table_",input$posi_lon, "_", input$posi_lat, ".csv" ) },
    content = function(file) {
      df <- dist_table()
      req(nrow(df) > 0)
      write.csv(df, file = file, row.names = FALSE)
    }
  )
  
  
  return(reactive({ data }))
}



