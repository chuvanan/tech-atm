

library(rvest)
library(glue)
library(tibble)

base_url = "https://www.techcombank.com.vn/mang-luoi-dia-diem-atm/danh-sach-chi-nhanh-phong-giao-dich-va-atm?fKeyword=&fCityId=0&fDistrictId=0&chkBranch=True&chkAtm=True&chkPriority=True&lng=0&lat=0&page={n_page}&pageItems={n_page_item}"

## -----------------------------------------------------------------------------
## API

get_atm_address = function(page) {
    out = page %>%
        html_nodes(xpath = "//div[@class='address']") %>%
        html_text(trim = T)
    out
}

get_atm_timer = function(page) {
    out = page %>%
        html_nodes(xpath = "//div[@class='timer']") %>%
        html_text(trim = T)
    out
}

get_atm_name = function(page) {
    out = page %>%
        html_nodes(xpath = "//div[@class='title-entries']") %>%
        html_text(trim = T)
    out
}

is_247_atm = function(page) {

    nodes = page %>%
        html_nodes(xpath = ".//div[@class='icon-list-atm']")
    out = logical(NROW(nodes))

    for (i in seq_along(out)) {
        out[i] = ifelse(is.na(html_node(nodes[i], xpath = ".//img[@alt='ATM 24/7']")), F, T)
    }
    out
}

is_priority = function(page) {

    nodes = page %>%
        html_nodes(xpath = ".//div[@class='icon-list-atm']")
    out = logical(NROW(nodes))

    for (i in seq_along(out)) {
        out[i] = ifelse(is.na(html_node(nodes[i], xpath = ".//img[@alt='Priority']")), F, T)
    }
    out

}

get_atm_info = function(url, n_page, n_page_item) {

    urls = glue(url, n_page = n_page, n_page_item = n_page_item)

    atm_names = character()
    atm_addresses = character()
    atm_timers = character()
    atm_247 = logical()
    atm_priority = logical()

    for (i in seq_along(urls)) {
        page = read_html(urls[i])
        atm_names = append(atm_names, get_atm_name(page))
        atm_247 = append(atm_247, is_247_atm(page))
        atm_priority = append(atm_priority, is_priority(page))
        atm_addresses = append(atm_addresses, get_atm_address(page))
        atm_timers = append(atm_timers, get_atm_timer(page))
        if (i > 1) Sys.sleep(2)
    }

    out = tibble(atm_names,
                 atm_247 = as.integer(atm_247),
                 atm_priority = as.integer(atm_priority),
                 crm = as.integer(grepl("CRM", atm_names)),
                 branch = as.integer(grepl("Techcombank", atm_names)),
                 atm_addresses,
                 atm_timers)
    out
}


## -----------------------------------------------------------------------------
## MAIN

techcom_atms = get_atm_info(base_url, n_page = 1, n_page_item = 849)
techcom_atms$province = trimws(stringr::word(techcom_atms$atm_addresses, -1, sep = ","))

## export
writexl::write_xlsx(techcom_atms, path = here::here("data/techcombank_atms.xlsx"))
