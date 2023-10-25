#library(magrittr)
#library(dplyr)
#library(mapproj)


library(groundhog)
#set.groundhog.folder("rpkg")
print("loaded groundhog")
pkgs <- c("magrittr", "dplyr", "tidyverse", "ggplot2", "maps", "mapproj")
groundhog.library(pkgs, "2023-10-01")
#library(tidyverse)
#library(ggplot2)
#library(maps)

taste <- read_csv( 
    "tc.csv", 
    show_col_types = FALSE
) %>% filter( 
    Parameter == "BITTER+SALTY" | Parameter == "BITTER+SOUR"
) %>% dplyr::select( 
    -c(
        Segments, 
        SegmentsB, 
        ID
    )
) %>% distinct(
    .keep_all = TRUE
) %>% group_by( 
    LanguageName, 
    Language, 
    Family, 
    Parameter, 
    Latitude, 
    Longitude
) %>% summarize( 
    Value = ifelse( 
        1 %in% Value, 
        1, 
        max(Value)
    ), .groups = "keep"	      
) %>% ungroup(
) %>% pivot_wider( 
    names_from = Parameter, 
    values_from = Value
)

print("Loaded the data")

world <- map_data( 
    "world", 
    wrap = c(-25, 335), 
    ylim = c(-56, 80),
    margin = T
)
lakes <- map_data( 
    "lakes", 
    wrap = c(-25, 335), 
    col = "white", 
    border = "gray", 
    ylim = c(-55, 65), 
    margin = T
)

print("Loaded maps")

taste <- taste %>% dplyr::mutate(
    Longitude = if_else(
        Longitude <= -25, 
        Longitude + 360, 
        Longitude
    )
)

basemap <- ggplot(
    taste
) + geom_polygon( 
    data = world, 
    aes( 
        x = long, 
        y = lat, 
        group = group
    ), 
    colour = "gray87", 
    fill = "gray87", 
    linewidth = 0.5
) + geom_polygon( 
    data = lakes, 
    aes(
        x = long, 
        y = lat, 
        group = group
    ), 
    colour = "gray87", 
    fill = "white", 
    linewidth = 0.3
) + theme(
    panel.grid.major = element_blank(), 
    panel.grid.minor = element_blank(), 
    axis.title.x = element_blank(), 
    axis.title.y = element_blank(), 
    axis.line = element_blank(), 
    panel.border = element_blank(), 
    panel.background = element_rect(
        fill = "white"
    ), 
    axis.text.x = element_blank(), 
    axis.text.y = element_blank(), 
    axis.ticks = element_blank()
) + coord_map(
    projection = "vandergrinten", 
    ylim = c(-56, 67)
)

print("prepared the basemap")

taste <- taste %>% dplyr::mutate(
    `BITTER+SOUR` = as.factor(`BITTER+SOUR`), 
    `BITTER+SALTY` = as.factor(`BITTER+SALTY`)
) 

taste_1 <- taste %>% filter(
    !is.na(`BITTER+SOUR`)
) %>% dplyr::mutate(
    Colexification = `BITTER+SOUR`
) 

taste_2 <- taste %>% filter(
    !is.na(`BITTER+SALTY`)
) %>% dplyr::mutate(
    Colexification = `BITTER+SALTY`
)

print("extracted parts from data")

p_1 <- basemap + geom_point(
    data = taste_1, 
    aes(
        x = Longitude, 
        y = Latitude, 
        shape = `BITTER+SOUR`, 
        colour = `BITTER+SOUR` 
    ),
    alpha = 0.7, 
) + scale_color_manual(
    values = c("#009E73", "#E69F00"), 
    labels = c("absent", "present"), 
    name = "BITTER+SOUR"
) + scale_shape_manual(
    values = c(19, 17), 
    labels = c("absent", "present") 
) + ggplot2::theme(
    text = element_text(size = 17), 
    plot.margin = unit(c(0,-5, 0, -5), "cm")
)

print("plotted first base map")

p_2 <- basemap + geom_point(
    data = taste_2, 
    aes( 
        x = Longitude, 
        y = Latitude,                                         
        shape = `BITTER+SALTY`, 
        colour = `BITTER+SALTY` 
    ), 
    alpha = 0.7, 
) + scale_color_manual(
    values = c("#009E73", "#E69F00"), 
    labels = c("absent", "present"), 
    name = "BITTER+SALTY"
) + scale_shape_manual(
    values = c(19, 17), 
    labels = c("absent", "present")
) + ggplot2::theme(
    text = element_text(
        size = 17
    ), 
    plot.margin = unit(c(0,-5, 0, -5), "cm" )
)

print("plotted second base map")
taste_2 <- taste_2 %>% dplyr::mutate(
    Sino_Tibetan = ifelse(
        Family == "Sino-Tibetan", 1, 0 
    ) 
) %>% dplyr::mutate(Sino_Tibetan = as.factor(Sino_Tibetan))

p_3 <- basemap + geom_point(
    data = taste_2, 
    aes(
        x = Longitude, 
        y = Latitude, 
        shape = `BITTER+SALTY`, 
        colour = `BITTER+SALTY`, 
        alpha = Sino_Tibetan
    )
) + scale_color_manual(
    values = c("#009E73", "#E69F00"), 
    labels = c("absent", "present"), 
    name = "BITTER+SALTY"
) + scale_shape_manual(
    values = c(19, 17), 
    labels = c("absent", "present")
) + scale_alpha_manual(
    values = c(0.5, 1), 
    name = "Sino-Tibetan", 
    guide = "none" 
) + ggplot2::theme(
    text = element_text(
        size = 17 
    ), 
    plot.margin = unit(c(0, -5, 0, -5), "cm") 
) + coord_map(
    ylim = c(12, 40), 
    xlim = c(82, 115) 
)

print("plotted last base map")
print(p_1)
ggsave("bitter-sour.pdf", width=12, height=4)
print(p_2)
ggsave("bitter-salty.pdf", width=12, height=4)
print(p_3)
ggsave("bitter-salty-zoom.pdf", width=8, height=4)


