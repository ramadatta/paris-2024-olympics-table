# Paris 2024 Olympics: Medal Performance Analysis
# 2025 Table Contest Submission
#
# A focused, clean analysis of top-performing nations at Paris 2024,
# featuring medal counts, efficiency metrics, and top disciplines.
# Designed for clarity and visual impact.

library(gt)
library(gtExtras)
library(tidyverse)

# Load data
medals <- read_csv("medals.csv", show_col_types = FALSE)
athletes <- read_csv("athletes.csv", show_col_types = FALSE)

# Process medal data
medal_summary <- medals %>%
  group_by(country, country_code) %>%
  summarise(
    gold = sum(medal_type == "Gold Medal"),
    silver = sum(medal_type == "Silver Medal"),
    bronze = sum(medal_type == "Bronze Medal"),
    total_medals = n(),
    # Top 3 disciplines
    top_sports = paste(
      head(names(sort(table(discipline), decreasing = TRUE)), 3), 
      collapse = " • "
    ),
    .groups = "drop"
  ) %>%
  # Add athlete efficiency
  left_join(
    athletes %>%
      group_by(country_code) %>%
      summarise(athlete_count = n_distinct(code), .groups = "drop"),
    by = "country_code"
  ) %>%
  mutate(
    athlete_count = replace_na(athlete_count, 1),
    efficiency = round(total_medals / athlete_count, 2),
    gold_pct = round((gold / total_medals) * 100, 1),
    # Medal quality score (weighted)
    medal_score = round((gold * 3 + silver * 2 + bronze * 1) / total_medals, 2)
  ) %>%
  arrange(desc(gold), desc(silver), desc(bronze)) %>%
  mutate(rank = row_number()) %>%
  filter(rank <= 15) %>%
  select(rank, country, country_code, gold, silver, bronze, total_medals,
         gold_pct, medal_score, efficiency, top_sports)

# Create the table
olympics_table <- medal_summary %>%
  gt() %>%
  
  # Header
  tab_header(
    title = md("**PARIS 2024 SUMMER OLYMPICS**"),
    subtitle = md("*Medal Standings: Top 15 Nations by Gold Count*<br>July 26 - August 11, 2024")
  ) %>%
  
  # Country flags - universal converter
  text_transform(
    locations = cells_body(columns = country_code),
    fn = function(x) {
      flags <- c(
        "USA" = "🇺🇸", "CHN" = "🇨🇳", "JPN" = "🇯🇵", "GBR" = "🇬🇧",
        "AUS" = "🇦🇺", "NED" = "🇳🇱", "FRA" = "🇫🇷", "GER" = "🇩🇪",
        "ITA" = "🇮🇹", "CAN" = "🇨🇦", "BRA" = "🇧🇷", "NZL" = "🇳🇿",
        "KOR" = "🇰🇷", "ESP" = "🇪🇸", "HUN" = "🇭🇺", "UZB" = "🇺🇿",
        "KEN" = "🇰🇪", "NOR" = "🇳🇴", "IRL" = "🇮🇪", "SWE" = "🇸🇪",
        "GEO" = "🇬🇪", "UKR" = "🇺🇦", "ROU" = "🇷🇴", "BEL" = "🇧🇪"
      )
      paste0('<span style="font-size: 28px;">', flags[x], '</span>')
    }
  ) %>%
  
  # Column labels
  cols_label(
    rank = md("**Rank**"),
    country = md("**Nation**"),
    country_code = "",
    gold = html("<span style='color: #B8860B; font-size: 18px;'>●</span> Gold"),
    silver = html("<span style='color: #808080; font-size: 18px;'>●</span> Silver"),
    bronze = html("<span style='color: #8B4513; font-size: 18px;'>●</span> Bronze"),
    total_medals = md("**Total**"),
    gold_pct = md("**Gold<br>%**"),
    medal_score = md("**Medal<br>Score**"),
    efficiency = md("**Efficiency**"),
    top_sports = md("**Top 3 Disciplines**")
  ) %>%
  
  # Medal column styling
  tab_style(
    style = list(
      cell_fill(color = "#FFFBF0"),
      cell_text(weight = "600", size = px(14))
    ),
    locations = cells_body(columns = gold)
  ) %>%
  
  tab_style(
    style = list(
      cell_fill(color = "#F8F8F8"),
      cell_text(size = px(14))
    ),
    locations = cells_body(columns = silver)
  ) %>%
  
  tab_style(
    style = list(
      cell_fill(color = "#FFF5EB"),
      cell_text(size = px(14))
    ),
    locations = cells_body(columns = bronze)
  ) %>%
  
  # Highlight total
  tab_style(
    style = cell_text(weight = "bold", size = px(15)),
    locations = cells_body(columns = total_medals)
  ) %>%
  
  # Highlight high gold percentages
  tab_style(
    style = list(
      cell_fill(color = "#FFF3CD"),
      cell_text(weight = "bold", color = "#856404")
    ),
    locations = cells_body(columns = gold_pct, rows = gold_pct > 32)
  ) %>%
  
  # Highlight high medal scores
  tab_style(
    style = list(
      cell_text(weight = "bold", color = "#0055A4")
    ),
    locations = cells_body(columns = medal_score, rows = medal_score >= 2.5)
  ) %>%
  
  # Podium styling
  tab_style(
    style = list(
      cell_fill(color = "#FFD700"),
      cell_text(weight = "bold", color = "white", size = px(16))
    ),
    locations = cells_body(columns = rank, rows = rank == 1)
  ) %>%
  
  tab_style(
    style = list(
      cell_fill(color = "#C0C0C0"),
      cell_text(weight = "bold", color = "white", size = px(16))
    ),
    locations = cells_body(columns = rank, rows = rank == 2)
  ) %>%
  
  tab_style(
    style = list(
      cell_fill(color = "#CD7F32"),
      cell_text(weight = "bold", color = "white", size = px(16))
    ),
    locations = cells_body(columns = rank, rows = rank == 3)
  ) %>%
  
  # Format numbers
  fmt_number(
    columns = c(gold_pct, medal_score, efficiency),
    decimals = 1
  ) %>%
  
  # Column spanners
  tab_spanner(
    label = md("**MEDAL COUNTS**"),
    columns = c(gold, silver, bronze, total_medals)
  ) %>%
  
  tab_spanner(
    label = md("**PERFORMANCE METRICS**"),
    columns = c(gold_pct, medal_score, efficiency)
  ) %>%
  
  # Footnotes
  tab_footnote(
    footnote = "Percentage of total medals that are gold - indicates medal quality",
    locations = cells_column_labels(columns = gold_pct)
  ) %>%
  
  tab_footnote(
    footnote = "Weighted score: Gold=3pts, Silver=2pts, Bronze=1pt, divided by total medals. Higher is better.",
    locations = cells_column_labels(columns = medal_score)
  ) %>%
  
  tab_footnote(
    footnote = "Total medals per unique athlete - measures team depth and efficiency",
    locations = cells_column_labels(columns = efficiency)
  ) %>%
  
  tab_footnote(
    footnote = "Based on total medals won across all events in each discipline",
    locations = cells_column_labels(columns = top_sports)
  ) %>%
  
  # Source
  tab_source_note(
    source_note = md("**Data Source:** Paris 2024 Olympic Games • Kaggle: piterfm/paris-2024-olympic-summer-games<br>**Created with:** R {gt} 0.10+ & {gtExtras} 0.5+ • **Submission:** Posit Table Contest 2025")
  ) %>%
  
  # Table styling
  tab_options(
    # Header
    heading.background.color = "#0055A4",
    heading.title.font.size = px(34),
    heading.subtitle.font.size = px(15),
    heading.align = "left",
    heading.padding = px(18),
    
    # Column labels
    column_labels.background.color = "#E8EAF6",
    column_labels.font.weight = "bold",
    column_labels.font.size = px(14),
    column_labels.border.top.color = "#0055A4",
    column_labels.border.top.width = px(3),
    column_labels.border.bottom.color = "#0055A4",
    column_labels.border.bottom.width = px(2),
    column_labels.padding = px(12),
    
    # Body
    table.font.size = px(13),
    table.background.color = "#FFFFFF",
    data_row.padding = px(12),
    
    # Borders
    table.border.top.width = px(3),
    table.border.top.color = "#0055A4",
    table.border.bottom.width = px(3),
    table.border.bottom.color = "#0055A4",
    table_body.border.bottom.color = "#E0E0E0",
    table_body.border.bottom.width = px(1),
    
    # Footer
    footnotes.background.color = "#F8F9FA",
    footnotes.font.size = px(11),
    footnotes.padding = px(14),
    source_notes.background.color = "#E8EAF6",
    source_notes.font.size = px(11),
    source_notes.padding = px(14)
  ) %>%
  
  # Alignment
  cols_align(
    align = "center",
    columns = c(rank, country_code, gold, silver, bronze, 
                total_medals, gold_pct, medal_score, efficiency)
  ) %>%
  
  cols_align(
    align = "left",
    columns = c(country, top_sports)
  ) %>%
  
  # Column widths
  cols_width(
    rank ~ px(60),
    country_code ~ px(70),
    country ~ px(150),
    gold ~ px(80),
    silver ~ px(80),
    bronze ~ px(80),
    total_medals ~ px(75),
    gold_pct ~ px(80),
    medal_score ~ px(85),
    efficiency ~ px(90),
    top_sports ~ px(220)
  ) %>%
  
  # Row striping
  opt_row_striping()

# Display
olympics_table

# Export
gtsave(olympics_table, "paris_2024_olympics_medal_table.html")
gtsave(olympics_table, "paris_2024_olympics_medal_table.png", 
       vwidth = 1600, vheight = 900)