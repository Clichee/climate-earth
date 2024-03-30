climate-earth
=============

Climate-earth project is a fork of Cameron Beccarios earth project and is developed as a Bachelor-Thesis to visualize climate data, based on the data published by [ECMWF](https://cds.climate.copernicus.eu/cdsapp#!/dataset/projections-cmip6?tab=overview).

building and launching
----------------------

After installing node.js and npm, clone "climate-earth" and install dependencies (`--recursive` can be left out if CMIP6 is not used):

    git clone https://github.com/ClimatePDE/climate-earth --recursive
    cd climate-earth
    npm install

Development web server can be launched by running the runner script called `run_{yourOS}` (`run_only_webapp_{yourOS}` if CMIP6 is not used). 

Or can be launched manually using:

    node dev-server.js 8080

Finally, point your browser to:

    http://localhost:8080

The server acts as a stand-in for static S3 bucket hosting and so contains almost no server-side logic. It
serves all files located in the `earth/public` directory. See `public/index.html` and `public/libs/earth/*.js`
for the main entry points. Data files are located in the `public/data` directory.

*For Ubuntu, Mint, and elementary OS, use `nodejs` instead of `node` instead due to a [naming conflict](https://github.com/joyent/node/wiki/Installing-Node.js-via-package-manager#ubuntu-mint-elementary-os).

getting climate data
--------------------

### CMIP6 data
Climate data can be automatically fetched, while using the web app if the backend server (submodule) is also running and the preferred source is `CMIP6`.
Simply selecting a date and pressing `GO!`, will fetch the climate data from the `CMIP6` servers.
Keep in mind, that if you want to use the CMIP6 servers, it is required to do the first step of their [How to use the CDS API](https://cds.climate.copernicus.eu/api-how-to). This will require an account on their website.

### Local data
If you want to use your own climate or wind data, simply put the JSON files in the `public/data/weather/temp` / `public/data/weather/wind` directories.

The climate data has the filename format: `surfAirTemp_YYYY-MM-DD.json`.

The wind data has the filename format: `wind_YYYY-MM-DD.json`.

### JSON format 
The climate and wind data have specific JSON format. Please take a look at the sample files left in the directory for local data.
The variables can be explained as the following:
1. **refTime** Refers to the datetime of the data in format yyyy-mm-
   ddThh:mm.SSSZ    
   The ’T’ and ’Z’ are no placeholders and the time can be set to whatever,
   since the data is a collection over an entire day
2. **forecastTime** Is an offset for the hours, which is also irrelevant and can
be set to 0
3. **parameterNumber** The amount of parameters. Will stay 1, since it
only has 1 data array
4. **parameterUnit** Unit of the data (K, °C or °F)
5. **nx** Grids in X-Axis. Size of lon array
6. **ny** Grids in Y-Axis. Size of lat array
7. **lo1** Rendering starting point on longitude (optional)
8. **la1** Rendering starting point on latitude (optional)
9. **lo2** Rendering end point on longitude. Without function, but may be
used in the future (optional)
10. **la2** Rendering end point on latitude. Without function, but may be used
in the future (optional)
11. **dx** Step size on the X-Axis. Step size of longitude.
12. **dy** Step size on the Y-Axis. Step size of latitude.
13. **data** Array with the temp/tasmax data. Is
of size: nx · ny

`lo1`, `la1`, `lo2` and `la2` are currently not used in this project and can therefore be left out. May change in the future.

Climate and wind data have both 2 header and data entries, but in case of the climate data, the second ones will be left empty (but should not be deleted!).
In case of wind data: First entry represents `U` vector, second represents `V` vector of the data. 

getting map data
----------------

Map data is provided by [Natural Earth](http://www.naturalearthdata.com) but must be converted to
[TopoJSON](https://github.com/mbostock/topojson/wiki) format. We make use of a couple different map scales: a
simplified, larger scale for animation and a more detailed, smaller scale for static display. After installing
[GDAL](http://www.gdal.org/) and TopoJSON (see [here](http://bost.ocks.org/mike/map/#installing-tools)), the
following commands build these files:

    curl "https://www.naturalearthdata.com/http//www.naturalearthdata.com/download/50m/physical/ne_50m_coastline.zip"
    curl "https://www.naturalearthdata.com/http//www.naturalearthdata.com/download/50m/physical/ne_50m_lakes.zip"
    curl "https://www.naturalearthdata.com/http//www.naturalearthdata.com/download/110m/physical/ne_110m_coastline.zip"
    curl "https://www.naturalearthdata.com/http//www.naturalearthdata.com/download/110m/physical/ne_110m_lakes.zip"
    curl "https://www.naturalearthdata.com/http//www.naturalearthdata.com/download/110m/cultural/ne_110m_admin_0_boundary_lines_land.zip"
    curl "https://www.naturalearthdata.com/http//www.naturalearthdata.com/download/50m/cultural/ne_50m_admin_0_boundary_lines_land.zip"
    unzip -o ne_\*.zip
    ogr2ogr -f GeoJSON coastline_50m.json ne_50m_coastline.shp
    ogr2ogr -f GeoJSON coastline_110m.json ne_110m_coastline.shp
    ogr2ogr -f GeoJSON -where "scalerank < 4" lakes_50m.json ne_50m_lakes.shp
    ogr2ogr -f GeoJSON -where "scalerank < 2 AND admin='admin-0'" lakes_110m.json ne_110m_lakes.shp
    ogr2ogr -f GeoJSON -simplify 1 coastline_tiny.json ne_110m_coastline.shp
    ogr2ogr -f GeoJSON -simplify 1 -where "scalerank < 2 AND admin='admin-0'" lakes_tiny.json ne_110m_lakes.shp
    ogr2ogr -f GeoJSON boundaries_50m.json ne_50m_boundaries.shp
    ogr2ogr -f GeoJSON boundaries_110m.json ne_110m_boundaries.shp
    topojson -o earth-topo.json coastline_50m.json coastline_110m.json lakes_50m.json lakes_110m.json boundaries_50m.json boundaries_110m.json
    topojson -o earth-topo-mobile.json coastline_110m.json coastline_tiny.json lakes_110m.json lakes_tiny.json
    cp earth-topo*.json <earth-git-repository>/public/data/

getting weather data
--------------------

Weather data is produced by the [Global Forecast System](http://en.wikipedia.org/wiki/Global_Forecast_System) (GFS),
operated by the US National Weather Service. Forecasts are produced four times daily and made available for
download from [NOMADS](http://nomads.ncep.noaa.gov/). The files are in [GRIB2](http://en.wikipedia.org/wiki/GRIB)
format and contain over [300 records](http://www.nco.ncep.noaa.gov/pmb/products/gfs/gfs.t00z.pgrbf00.grib2.shtml).
We need only a few of these records to visualize wind data at a particular isobar. The following commands download
the 1000 hPa wind vectors and convert them to JSON format using the [grib2json](https://github.com/cambecc/grib2json)
utility:

    YYYYMMDD=<a date, for example: 20140101>
    curl "http://nomads.ncep.noaa.gov/cgi-bin/filter_gfs.pl?file=gfs.t00z.pgrb2.1p00.f000&lev_10_m_above_ground=on&var_UGRD=on&var_VGRD=on&dir=%2Fgfs.${YYYYMMDD}00" -o gfs.t00z.pgrb2.1p00.f000
    grib2json -d -n -o current-wind-surface-level-gfs-1.0.json gfs.t00z.pgrb2.1p00.f000
    cp current-wind-surface-level-gfs-1.0.json <earth-git-repository>/public/data/weather/current

font subsetting
---------------

This project uses [M+ FONTS](http://mplus-fonts.sourceforge.jp/). To reduce download size, a subset font is
constructed out of the unique characters utilized by the site. See the `earth/server/font/findChars.js` script
for details. Font subsetting is performed by the [M+Web FONTS Subsetter](http://mplus.font-face.jp/), and
the resulting font is placed in `earth/public/styles`.

[Mono Social Icons Font](http://drinchev.github.io/monosocialiconsfont/) is used for scalable, social networking
icons. This can be subsetted using [Font Squirrel's WebFont Generator](http://www.fontsquirrel.com/tools/webfont-generator).

implementation notes
--------------------

Building this project required solutions to some interesting problems. Here are a few:

   * The GFS grid has a resolution of 1°. Intermediate points are interpolated in the browser using [bilinear
     interpolation](http://en.wikipedia.org/wiki/Bilinear_interpolation). This operation is quite costly.
   * Each type of projection warps and distorts the earth in a particular way, and the degree of distortion must
     be calculated for each point (x, y) to ensure wind particle paths are rendered correctly. For example,
     imagine looking at a globe where a wind particle is moving north from the equator. If the particle starts
     from the center, it will trace a path straight up. However, if the particle starts from the globe's edge,
     it will trace a path that curves toward the pole. [Finite difference approximations](http://gis.stackexchange.com/a/5075/23451)
     are used to estimate this distortion during the interpolation process.
   * The SVG map of the earth is overlaid with an HTML5 Canvas, where the animation is drawn. Another HTML5
     Canvas sits on top and displays the colored overlay. Both canvases must know where the boundaries of the
     globe are rendered by the SVG engine, but this pixel-for-pixel information is difficult to obtain directly
     from the SVG elements. To workaround this problem, the globe's bounding sphere is re-rendered to a
     detached Canvas element, and the Canvas' pixels operate as a mask to distinguish points that lie outside
     and inside the globe's bounds.
   * Most configuration options are persisted in the hash fragment to allow deep linking and back-button
     navigation. I use a [backbone.js Model](http://backbonejs.org/#Model) to represent the configuration.
     Changes to the model persist to the hash fragment (and vice versa) and trigger "change" events which flow to
     other components.
   * Components use [backbone.js Events](http://backbonejs.org/#Events) to trigger changes in other downstream
     components. For example, downloading a new layer produces a new grid, which triggers reinterpolation, which
     in turn triggers a new particle animator. Events flow through the page without much coordination,
     sometimes causing visual artifacts that (usually) quickly disappear.
   * There's gotta be a better way to do this. Any ideas?

inspiration
-----------

The awesome [hint.fm wind map](http://hint.fm/wind/) and [D3.js visualization library](http://d3js.org) provided
the main inspiration for this project.
