# Paris 2024 Olympics Medal Performance Analysis

## Overview
An analysis of the top 15 medal-winning nations at the Paris 2024 Summer Olympics, 
featuring medal counts, efficiency metrics, and performance indicators.

## Features
- **Medal Standings**: Gold, silver, bronze counts with Olympic-themed styling
- **Performance Metrics**: Gold percentage, weighted medal score, and athlete efficiency
- **Top Disciplines**: Each nation's three strongest sports
- **Visual Design**: Podium-style ranking (1st=gold, 2nd=silver, 3rd=bronze)

## Data Source
- **Dataset**: [Paris 2024 Olympic Summer Games](https://www.kaggle.com/datasets/piterfm/paris-2024-olympic-summer-games)
- **Files Used**: medals.csv, athletes.csv
- **Processing**: Medal counts aggregated by country, athlete efficiency calculated

## Key Metrics Explained
- **Gold %**: Percentage of medals that are gold (indicates medal quality)
- **Medal Score**: Weighted average (Gold=3pts, Silver=2pts, Bronze=1pt / total)
- **Efficiency**: Medals per unique athlete (measures team depth)

## Running the Code
```r
# Install required packages
install.packages(c("gt", "gtExtras", "tidyverse"))

# Run the script
source("paris_2024_olympics.R")
