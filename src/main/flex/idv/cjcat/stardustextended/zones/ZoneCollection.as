package idv.cjcat.stardustextended.zones
{

import idv.cjcat.stardustextended.xml.XMLBuilder;
import idv.cjcat.stardustextended.geom.MotionData2D;

public class ZoneCollection
{
    public var zones : Vector.<Zone> = new Vector.<Zone>();

	public function ZoneCollection():void
	{	
	}

    [Inline]
    public final function getRandomPointInZones() : MotionData2D
    {
        var md2D : MotionData2D;
        var numZones : uint = zones.length;
        if (numZones > 1) {
            var sumArea : Number = 0;
            var areas : Vector.<Number> = new Vector.<Number>();
            for (var i : int = 0; i < numZones; i++) {
                sumArea += Zone(zones[i]).getArea();
                areas.push(sumArea);
            }
            var position : Number = Math.random() * sumArea;
            for (i = 0; i < areas.length; i++) {
                if (position <= areas[i]) {
                    md2D = zones[i].getPoint();
                    break;
                }
            }
        }
        else if (numZones == 1) {
            md2D = zones[0].getPoint();
        }
        return md2D; // returns null if there are no zones
    }

    [Inline]
    public final function contains(xc : Number, yc : Number) : Boolean
    {
        var contains : Boolean = false;
        for each (var zone : Zone in zones) {
            if (zone.contains(xc, yc)) {
                contains = true;
                break;
            }
        }
        return contains;
    }

    [Inline]
    public final function addToStardustXML(stardustXML : XML) : void
    {
        if (zones.length > 0) {
            stardustXML.appendChild(<zones/>);
            var zone : Zone;
            for each (zone in zones) {
                stardustXML.zones.appendChild(zone.getXMLTag());
            }
        }
    }

    [Inline]
    public final function parseFromStardustXML(stardustXML : XML, builder : XMLBuilder) : void
    {
        zones = new Vector.<Zone>();
        for each (var node : XML in stardustXML.zones.*) {
            zones.push(Zone(builder.getElementByName(node.@name)));
        }
    }
}
}
