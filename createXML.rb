require 'rubygems'

def putHeader()
  puts '<?xml version="1.0" encoding="UTF-8"?>'
  puts '<kml xmlns="http://www.opengis.net/kml/2.2" xmlns:gx="http://www.google.com/kml/ext/2.2" xmlns:kml="http://www.opengis.net/kml/2.2" xmlns:atom="http://www.w3.org/2005/Atom">'
  puts '<Document>'
  puts '        <name>driveTimes.kml</name>'
  puts' <open>1</open>'
end

def putFooter()
  puts '</Document>'
  puts '</kml>'
end


def putStyle(color,name)
  puts '  <StyleMap id="' + name + '">'
  puts '    <Pair>'
  puts '      <key>normal</key>'
  puts '        <styleUrl>' + name + 'style</styleUrl>'
  puts '    </Pair>'
  puts '    <Pair>'
  puts '      <key>normal</key>'
  puts '        <styleUrl>' + name + 'style</styleUrl>'
  puts '    </Pair>'
  puts '  </StyleMap>'
  puts '  <Style id="' + name + 'style">'
  puts '    <IconStyle>'
  puts '      <color>' + color + '</color>'
  puts '      <scale>0.8</scale>'
  puts '      <Icon>'
  puts '        <href>http://maps.google.com/mapfiles/kml/shapes/shaded_dot.png</href>'
  puts '      </Icon>'
  puts '      <hotSpot x="32" y="1" xunits="pixels" yunits="pixels"/>'
  puts '    </IconStyle>'
  puts '    <LabelStyle>'
  puts '      <color>ffffffff</color>'
  puts '      <scale>0</scale>'
  puts '    </LabelStyle>'
  puts '    <ListStyle>'
  puts '      <ItemIcon>'
  puts '        <href>http://maps.google.com/mapfiles/kml/shapes/shaded_dot.png</href>'
  puts '      </ItemIcon>'
  puts '    </ListStyle>'
  puts '  </Style>'
end


def putPlacemark(coords,name,times)
  coordArr = coords.split(",")

  puts '  <Placemark>'
  puts '    <name>' + name + '</name>'
  puts '    <LookAt>'
  puts '      <longitude>' + coordArr[0] + '</longitude>'
  puts '      <latitude>' + coordArr[1] + '</latitude>'
  puts '      <altitude>0</altitude>'
  puts '      <heading>-0.02731824760056736</heading>'
  puts '      <gx:altitudeMode>relativeToSeaFloor</gx:altitudeMode>'
  puts '    </LookAt>'
  puts '    <styleUrl>#' + name + 'style</styleUrl>'
  puts '    <Point>'
  puts '      <gx:drawOrder>1</gx:drawOrder>'
  puts '      <coordinates>' + coords + ',0</coordinates>'
  puts '    </Point>'
  puts '    <gx:balloonVisibility>1</gx:balloonVisibility>'
  puts '    <address>' + times.join("    ") + '</address>'
  puts '  </Placemark>'
end

#In theory, this gives some color to the points so you can visualize the distances
#in practice, this color scheme is pretty meh.
def getColor(d1, d2, d3)
  max=3600 #one hour= maximum color

  hex = "ff"
  for i in [d1,d2,d3]
    if i.to_i > 3600
      i = 3600
    end
    i = (255-((i.to_i*255)/3600).to_i).to_s(16)

    #pad hex if necessary
    if i.length == 1
      i = "0" + i
    end
    if hex.nil?
      hex = i
    else
      hex = hex + i
    end
  end
  return hex
end

#----------------------------------------

putHeader()
marks = Array.new;
styles = Array.new

dups = Hash.new
File.open(ARGV[0], "r").each_line do |line|
  arr = line.split("\t")

  #swap coords
  tmp = arr[0].split(",")

  tmp[0]=tmp[0].to_f.round(8)
  tmp[1]=tmp[1].to_f.round(8)
  coords = [tmp[1],tmp[0]].join(",")

  if(dups.has_key?(coords))
    next;
  end
  dups[coords] = 1;

  color = getColor(arr[1],arr[2],arr[3])
  seconds = [arr[1],arr[2],arr[3]]
  minutes = []
  seconds.each do |sec|
    minutes.push((sec.to_f/60).round(2))
  end
  times = ["Site 1: #{minutes[0]}","Site 2: #{minutes[1]}","Site 3: #{minutes[2]}"]

  name =  coords.split(",").join("")

  plot = TRUE

  #only output points that are within N minutes of the sites, 
  #weight them according to your preferences
  if(minutes[0] > 20) #Site 1
    plot = FALSE
  end
  if(minutes[1] > 30) #Site 2
    plot = FALSE
  end
  if(minutes[2] > 30) #Site 3
    plot = FALSE
  end


  if plot
    putStyle(color,name)
    putPlacemark(coords,name,times)
  end
end

putFooter()
