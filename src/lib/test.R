library(plotly)
library(ggplot2)

p <- ggplot(mpg, aes(displ, hwy, colour = class, size = hwy)) +
  geom_point()

plotly_json(p, pretty = FALSE)
