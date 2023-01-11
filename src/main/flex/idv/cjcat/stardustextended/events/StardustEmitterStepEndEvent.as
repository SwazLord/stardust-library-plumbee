package idv.cjcat.stardustextended.events
{
import flash.events.Event;

import idv.cjcat.stardustextended.emitters.Emitter;

public class StardustEmitterStepEndEvent extends Event
{

    public static const TYPE : String = "StardustEmitterStepEndEvent";

    private var _emitter:Emitter;

    public function StardustEmitterStepEndEvent(emitter:Emitter)
    {
        super(TYPE);
        _emitter = emitter;
    }

    public function get emitter() : Emitter
    {
        return _emitter;
    }

    override public function clone() : Event
    {
        return new StardustEmitterStepEndEvent(_emitter);
    }
}
}
