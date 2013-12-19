require 'rubygems'
require 'json'
require 'net/http'

def fetch(url)
   resp = Net::HTTP.get_response(URI.parse(url))
   data = resp.body
   JSON.parse(data)
end

def seconds(start,stop)
  sleep(0.5)
  result = fetch "http://maps.googleapis.com/maps/api/directions/json?origin=#{start}&destination=#{stop}&sensor=false&alternatives=false"
  return result["routes"][0]["legs"][0]["duration"]["value"]
end

#these are the coordinates of the three sites that you'd like to map from
site1Coords = "39.996879,-91.999568"
site2Coords = "38.999999,-90.350232"
site3Coords = "38.777777,-91.666142"

# these are the coordinates defining the boundaries of the
# rectangle that you'd like to search within
top=39.999999
left=-90.000000
bottom=38.999999
right=-91.000000

# the google API only allows 2500 requests per day, so base our resolution on this limit.
# 27x27 (times 3 locations) gets us in the neighborhood and leaves some breathing room for false starts, testing, etc. 
vinc = (top-bottom)/27
hinc = (right-left).abs/27

# if you want to alter the spacing to add resolution to a subsequent run,
# modify the start coords here
#left = left +(hinc/2)
#top = top +(vinc/2)

vpos = top
hpos = left

while vpos >= bottom do
  while hpos <= right do
    thispos = vpos.to_s + "," + hpos.to_s
    $stderr.puts thispos
    puts [thispos, seconds(site1Coords,thispos), seconds(site2Coords,thispos), seconds(site3Coords, thispos)].join("\t")
    hpos = hpos + hinc
  end
  hpos = left
  vpos = vpos - vinc;
end

