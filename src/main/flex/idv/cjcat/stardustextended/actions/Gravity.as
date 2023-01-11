package idv.cjcat.stardustextended.actions
{

import idv.cjcat.stardustextended.StardustElement;
import idv.cjcat.stardustextended.emitters.Emitter;
import idv.cjcat.stardustextended.fields.Field;
import idv.cjcat.stardustextended.fields.UniformField;
import idv.cjcat.stardustextended.geom.MotionData2D;
import idv.cjcat.stardustextended.geom.MotionData2DPool;
import idv.cjcat.stardustextended.particles.Particle;
import idv.cjcat.stardustextended.xml.XMLBuilder;

/**
 * Applies accelerations to particles according to the associated gravity fields, in pixels.
 * @see idv.cjcat.stardustextended.fields.Field
 */
public class Gravity extends Action implements IFieldContainer
{

    protected var _fields : Vector.<Field>;

    public function Gravity(fields : Vector.<Field> = null)
    {
        priority = -3;
        if (fields) {
            _fields = fields;
        }
        else {
            _fields = new Vector.<Field>();
            _fields.push(new UniformField(0, 1));
        }
    }

    public function get fields() : Vector.<Field>
    {
        return _fields;
    }

    public function set fields(value : Vector.<Field>) : void
    {
        _fields = value;
    }

    /**
     * Adds a gravity field to the simulation.
     * @param field
     */
    public function addField(field : Field) : void
    {
        if (_fields.indexOf(field) < 0) _fields.push(field);
    }

    /**
     * Removes a gravity field from the simulation.
     * @param field
     */
    public function removeField(field : Field) : void
    {
        var index : int = _fields.indexOf(field);
        if(index >= 0) _fields.removeAt(index);
    }

    /**
     * Removes all gravity fields from the simulation.
     */
    public function clearFields() : void
    {
        _fields = new Vector.<Field>();
    }

	private var _updateMd2D:MotionData2D; 
	private var _ui:int, _uLen:uint;
	
    override public function update(emitter : Emitter, particle : Particle, timeDelta : Number, currentTime : Number) : void
    {
        timeDelta = timeDelta * 100; // acceleration is in m/(s*s)

        for(_ui = 0, _uLen = _fields.length; _ui < _uLen; _ui++)
		{
			_updateMd2D = _fields[_ui].getMotionData2D(particle);

            if(_updateMd2D)
			{
                particle.vx += _updateMd2D.x * timeDelta;
                particle.vy += _updateMd2D.y * timeDelta;
                MotionData2DPool.recycle(_updateMd2D);
            }
        }
    }

    //XML
    //------------------------------------------------------------------------------------------------

    override public function getRelatedObjects() : Vector.<StardustElement>
    {
        return Vector.<StardustElement>(_fields);
    }

    override public function getXMLTagName() : String
    {
        return "Gravity";
    }

    override public function toXML() : XML
    {
        var xml : XML = super.toXML();

        if (_fields.length > 0) {
            xml.appendChild(<fields/>);
            var field : Field;
            for each (field in _fields) {
                xml.fields.appendChild(field.getXMLTag());
            }
        }

        return xml;
    }

    override public function parseXML(xml : XML, builder : XMLBuilder = null) : void
    {
        super.parseXML(xml, builder);

        clearFields();
        for each (var node : XML in xml.fields.*) {
            addField(builder.getElementByName(node.@name) as Field);
        }
    }

    //------------------------------------------------------------------------------------------------
    //end of XML
}
}