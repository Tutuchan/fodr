
<!-- README.md is generated from README.Rmd. Please edit that file -->

# fodr

`fodr` is an R package to access various French Open Data portals.

Many of those portals use the OpenDataSoft platform to make their data
available and this platform can be accessed with the [OpenDataSoft
APIs](https://docs.opendatasoft.com/en/api/catalog_api.html).

`fodr` wraps this API to make it easier to retrieve data directly in R.

## Installation

The `devtools` package is needed to install `fodr`:

``` r
devtools::install_github("tutuchan/fodr")
```

## Portals

#### Available portals

The following portals are currently available with `fodr`:

``` r
library(fodr)
list_portals()
#> # A tibble: 15 x 3
#>    name                                 portals   base_urls                
#>    <chr>                                <chr>     <chr>                    
#>  1 RATP                                 ratp      http://data.ratp.fr      
#>  2 Région Ile-de-France                 iledefra… http://data.iledefrance.…
#>  3 Infogreffe                           infogref… http://datainfogreffe.fr 
#>  4 Toulouse Métropole                   toulouse  https://data.toulouse-me…
#>  5 STAR                                 star      https://data.explore.sta…
#>  6 Issy-les-Moulineaux                  issy      http://data.issy.com     
#>  7 STIF                                 stif      http://opendata.stif.info
#>  8 Paris                                paris     http://opendata.paris.fr 
#>  9 Tourisme Alpes-Maritimes             04        http://tourisme04.openda…
#> 10 Tourisme Pas-de-Calais               62        http://tourisme62.openda…
#> 11 Département des Hauts-de-Seine       92        https://opendata.hauts-d…
#> 12 Ministère de l'Education Nationale,… enesr     http://data.enseignement…
#> 13 ERDF                                 erdf      https://data.erdf.fr     
#> 14 RTE                                  rte       https://opendata.rte-fra…
#> 15 OpenDataSoft Public                  ods       https://public.opendatas…
```

The portals have been identified from the [Open Data
Inception](http://opendatainception.io) website. Many of these portals
do not actually contain data and a large number of them are available
*via* the ArcGIS Open platform. This API will be supported in a future
release.

#### Retrieve datasets on a portal

Use the `fodr_portal` function with the corresponding **fodr slug** to
create a `FODRPortal` object:

``` r
library(fodr)
portal <- fodr_portal("paris")
portal
#> FODRPortal object
#> ---------------------------------------------------------------
#> Portal: paris 
#> Number of datasets: 249 
#> Themes:
#>   - Administration et Finances Publiques
#>   - Citoyenneté
#>   - Commerces
#>   - Culture
#>   - Environnement
#>   - Equipements, Services, Social
#>   - Mobilité et Espace Public
#>   - Services
#>   - Urbanisme et Logements 
#> ---------------------------------------------------------------
```

The `search` method allows you to find datasets on this portal (see the
function documentation for more information). By default, and contrary
to the Open Data Soft API, all elements satisfying the search are
returned.

Let’s look at the datasets that contain the word *vote*:

``` r
list_datasets <-  portal$search(q = "vote")
#> 36 datasets found ...
list_datasets[[1]]
#> FODRDataset object
#> ---------------------------------------------------------------
#> Dataset id: secteurs-des-bureaux-de-vote 
#> Theme: Citoyenneté 
#> Keywords: bureau de vote, elections, votes, suffrages 
#> Publisher: Mairie de Paris / Direction de la Démocratie, des Citoyens et des Territoires 
#> ---------------------------------------------------------------
#> Number of records: 896 
#> Number of files: 0 
#> Modified: 2017-03-30 
#> Sortables: objectid, nbr_elect_f, nbr_elect_e_m, nbr_elect_e_e, nbr_elect_l12, arrondissement, num_bv 
#> ---------------------------------------------------------------
#> Description:
#> Sectionnement des bureaux de vote en vigueur à partir du 01 mars 2017Donnée initialement en NTF Lambert Zone I(EPSG : 27561)et reprojetée en RGF 93 Lambert 93(EPSG : 2154) Représentation du sectionnement des bureaux de vote, applicable à partir du 1emars 2017.  La représentation du sectionnement ne se calque pas sur le bâti ou sur le parcellaire car c’est le rattachement au point-adresse qui est pris en considération.
#> ---------------------------------------------------------------
```

#### Retrieve datasets by theme

``` r
library(magrittr)
list_culture_datasets <-  portal$search(theme = "Culture")
#> 249 datasets found ...
lapply(list_culture_datasets, function(dataset) dataset$info$metas$theme) %>% 
  unlist() %>% 
  unique()%>% 
  sort()
#> [1] "Culture"
```

## Datasets

#### Retrieve records on a dataset

``` r
dts <- list_datasets[[1]]
dts$get_records()
#> # A tibble: 896 x 14
#>    shape_area objectid nbr_elect_l12 arrondissement validite shape_len
#>         <dbl>    <int>         <int>          <int> <chr>        <dbl>
#>  1          0        4             0             19 oui              0
#>  2          0        5             0             19 oui              0
#>  3          0        9             0             19 oui              0
#>  4          0       10             0             19 oui              0
#>  5          0       12             0             19 oui              0
#>  6          0       17             0             19 oui              0
#>  7          0       19             0             19 oui              0
#>  8          0       21             0             19 oui              0
#>  9          0       22             0             19 non              0
#> 10          0       29             0             19 non              0
#> # ... with 886 more rows, and 8 more variables: nbr_elect_f <int>,
#> #   nbr_elect_e_m <int>, nbr_elect_e_e <int>, num_bv <int>, id_bv <chr>,
#> #   lng <dbl>, lat <dbl>, geo_shape <list>
```

#### Filter records

``` r
dts <- list_datasets[[1]]
dts$get_records(nrows = dts$info$metas$records_count, refine = list(validite = "oui"))
#> # A tibble: 54 x 14
#>    shape_area objectid nbr_elect_l12 arrondissement validite shape_len
#>         <dbl>    <int>         <int>          <int> <chr>        <dbl>
#>  1          0        4             0             19 oui              0
#>  2          0        5             0             19 oui              0
#>  3          0        9             0             19 oui              0
#>  4          0       10             0             19 oui              0
#>  5          0       12             0             19 oui              0
#>  6          0       17             0             19 oui              0
#>  7          0       19             0             19 oui              0
#>  8          0       21             0             19 oui              0
#>  9          0       33             0             19 oui              0
#> 10          0       45             0             19 oui              0
#> # ... with 44 more rows, and 8 more variables: nbr_elect_f <int>,
#> #   nbr_elect_e_m <int>, nbr_elect_e_e <int>, num_bv <int>, id_bv <chr>,
#> #   lng <dbl>, lat <dbl>, geo_shape <list>
```

#### Download attachments

Some datasets have attached files in a pdf, docx, xlsx, … format. These
can be retrieved using the `get_attachments` method:

``` r
dts <- fodr_dataset("erdf", "coefficients-des-profils")
dts$get_attachments("DictionnaireProfils_1JUIL18.xlsb")
```

## GIS data

Some datasets have geographical information on each data point.

For these datasets, two additional columns will be present when fetching
records: `lng` and `lat` that correspond to the longitude and latitude
of the coordinates of the data point. Additionally, if there are shapes
associated to data points (polygons or linestrings for example), they
will be stored in the `geo_shape` column either as a list of
`data.frame`s with the same two columns `lng` and `lat` or in a list
`sf` objects if `sf` package is already installed. The latter allows a
straigtforward way to plot geometric data.

See for example the following dataset:

``` r
dts <- fodr_dataset("stif", "gares-routieres-idf")
dfRecords <- dts$get_records(nrows = 10)
dfRecords
#> # A tibble: 10 x 14
#>    gr_id dpt_id lda_nom gare_nom zdl_id insee_txt gr_nom comm_nom zdl_nom
#>    <int>  <int> <chr>   <chr>     <int> <chr>     <chr>  <chr>    <chr>  
#>  1    22     95 Argent… ARGENTE…  47875 95018     Argen… Argente… Argent…
#>  2   183     77 Combs-… COMBS-L…  45771 77122     Combs… Combs-l… Combs-…
#>  3   567     77 Nemour… NEMOURS…  43245 77431     Nemou… Saint-P… Nemour…
#>  4   338     78 Houill… HOUILLE…  47439 78311     Houil… Houilles Houill…
#>  5   854     91 Vigneu… VIGNEUX…  45735 91657     Vigne… Vigneux… Vigneu…
#>  6   571     94 Nogent… NOGENT-…  46552 94058     Nogen… Le Perr… Nogent…
#>  7   615     95 Persan… PERSAN-…  43178 95487     Persa… Persan   Persan…
#>  8   865     77 Villep… VILLEPA…  46725 77294     Ville… Mitry-M… Villep…
#>  9   758     93 Saint-… SAINT-O…  43203 93070     Saint… Saint-O… Saint-…
#> 10   690     77 Provin… PROVINS   47181 77379     Provi… Provins  Provin…
#> # ... with 5 more variables: acces_pmr <chr>, lda_id <int>, lng <dbl>,
#> #   lat <dbl>, geo_shape <list>
```

You can then use [leaflet](http://rstudio.github.io/leaflet/) to easily
plot this data on a map, either using data points:

``` r
library(leaflet)
leaflet(dfRecords) %>% 
  addProviderTiles("CartoDB.Positron") %>% 
  addMarkers(popup = ~gare_nom)
```

![leaflet
example](inst/images/Screenshot%202018-12-28%2015-42-00.png?raw=true
"Screenshot leaflet example")

or using the `geo_shape` column:

``` r
library(sf)
dfRecords[1,] %>% 
  st_as_sf() %>% 
  leaflet() %>% 
  addProviderTiles("CartoDB.Positron") %>% 
  addPolygons(label = ~gare_nom)
```

![leaflet
example](inst/images/Screenshot%202018-12-28%2015-43-36.png?raw=true
"Screenshot leaflet example")

## License of the data

Most of the data is available under the [Open
Licence](https://www.etalab.gouv.fr/licence-ouverte-open-licence)
([english PDF
version](https://www.etalab.gouv.fr/wp-content/uploads/2014/05/Open_Licence.pdf))
but double check if you are unsure.

## TODO

  - handle portals that require authentification,
  - handle ArcGIS-powered portals,
  - possibly handle navitia.io portals,
  - ?
