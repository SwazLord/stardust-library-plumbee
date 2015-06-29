﻿package idv.cjcat.stardustextended.twoD.initializers
{

import idv.cjcat.stardustextended.common.initializers.Initializer;
import idv.cjcat.stardustextended.common.particles.Particle;
import idv.cjcat.stardustextended.common.xml.XMLBuilder;
import idv.cjcat.stardustextended.twoD.actions.IZoneContainer;
import idv.cjcat.stardustextended.twoD.geom.MotionData2D;
import idv.cjcat.stardustextended.twoD.geom.MotionData2DPool;
import idv.cjcat.stardustextended.twoD.zones.Zone;
import idv.cjcat.stardustextended.twoD.zones.ZoneCollection;

/**
 * Sets a particle's position based on the <code>zone</code> property.
 *
 * <p>
 * A particle's position is determined by a random point in the zone.
 * </p>
 */
public class Position extends Initializer implements IZoneContainer
{
    protected var zoneCollection : ZoneCollection;
    public function get zones() : Vector.<Zone> { return zoneCollection.zones; }
    public function set zones(value : Vector.<Zone>) : void { zoneCollection.zones = value; }

    public function Position() {
        zoneCollection = new ZoneCollection();
    }

    override public function initialize(particle:Particle):void {
        var md2D : MotionData2D = zoneCollection.getRandomPointInZones();
        if (md2D)
        {
            particle.x = md2D.x;
            particle.y = md2D.y;
            MotionData2DPool.recycle(md2D);
        }
    }

    //XML
    //------------------------------------------------------------------------------------------------
    override public function getRelatedObjects():Array {
        return zoneCollection.toArray();
    }

    override public function getXMLTagName():String {
        return "Position";
    }

    override public function toXML():XML {
        var xml:XML = super.toXML();
        zoneCollection.addToStardustXML(xml);
        return xml;
    }

    override public function parseXML(xml : XML, builder : XMLBuilder = null):void {
        super.parseXML(xml, builder);
        zoneCollection.parseFromStardustXML(xml, builder);
    }

    //------------------------------------------------------------------------------------------------
    //end of XML
}
}