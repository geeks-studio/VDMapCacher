# VDMapCacher
Nice way to cache any map without permanent access to the Internet.

## Screenshots
<img src="http://drobinin.com/projects/vdmapcacher/preview3.png">
<img src="http://drobinin.com/projects/vdmapcacher/preview4.png">

## Usage
* In order to draw a line between two points, set up the cacher and provide a view to use as a basic layer.
```
mapCacher.delegate = self
mapCacher.departureCoords = [Constants.moscow]
mapCacher.arrivalCoords = [Constants.sydney]

let mapCacher = VDMapCacher()
mapCacher.generateMapForRouteInView(cell.imageView, line: 2.0)
```
Don't forget to subscribe to `ImageGeneratedProtocol` to know when the image is generated.

* In order to draw a bunch of lines, you'd better specify the final size of the image:
```
mapCacher.generateMapForRouteInView(imageView, line: 6.0, size: CGSize(width: 1900, height: 1000))
```
However, take into account that it's impossible to capture whole world by using MKMapSnapshotter (http://stackoverflow.com/questions/28796004/capturing-the-whole-world-with-mkmapsnapshotter), so seems like the basic solution with a casual map is a bit better.

## Demo
Feel free to check out the demo to get an idea about how these methods work.
