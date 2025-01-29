if(dir.exists(paste0("//ifw7ro-file.fws.doi.net/datamgt/mbm/"))==FALSE) {
  stop("Check the VPN connection and try again.")
}

project.folder<- FWSAkRDRtools::find.projects(pattern = "lb", program = "mbm")

mdDxnry.translate(project.folder, subfolder, all){
  if(missing(subfolder)){
    subfolder<- ""
  }
  if(missing(all)){
    all<- TRUE
  }


  path<- paste0("//ifw7ro-file.fws.doi.net/datamgt/mbm/",a,"/metadata/",subfolder)

  for(a in project.folder){


    metadata.files<- list.files(path)

    json.files<- metadata.files[which(tools::file_ext(metadata.files) %in% "json")]

    mdeditor.files<- json.files[stringr::str_detect(json.files,pattern = "mdeditor")]

    for (b in mdeditor.files) {

      mdeditor.import<-  rjson::fromJSON(file = paste0(path, b))


      mdeditor.dxnry<-  mdJSONdictio::extract.mdJSON(x = mdeditor.import, record.type = "dictionaries", all=TRUE)

      for (c  in mdeditor.dxnry[["data"]]) {

        temp<- list()
        temp[["data"]][[1]]<- c

        table.dxnry <- mdJSONdictio::build.table(x = temp)

        write.csv(
          table.dxnry,
          paste0(
            "//ifw7ro-file.fws.doi.net/datamgt/mbm/",
            a,
            "/metadata/",
            subfolder,
            temp[["data"]][[1]][["meta"]][["title"]],
            "_",
            format(
              as.POSIXct(temp[["data"]][[1]][["attributes"]][["date-updated"]], tz = "UTC", "%Y-%m-%dT%H:%M:%OS"),
              '%Y%m%d-%H%M%S'
            ),
            ".csv"
          ),
          na = "",
          row.names = FALSE
        )

      }
    }
  }


}







