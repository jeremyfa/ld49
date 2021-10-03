package ld49;

import ceramic.Component;
import ceramic.Entity;
import ceramic.Transform;
import ceramic.Visual;

class Floating extends Entity implements Component {

/// Properties

    public var amplitude:Float;

    public var rotation:Float;

    public var duration:Float;

    public var entity:Visual;

/// Lifecycle

    public function new(amplitude:Float = 8, rotation:Float = 11, duration:Float = 2.0) {

        super();

        this.amplitude = amplitude;
        this.rotation = rotation;
        this.duration = duration;

    }

    function bindAsComponent():Void {

        entity.transform = new Transform();

        tween(SINE_EASE_OUT, duration * 0.5, 0, -1, function(value, time) {
            applyRotation(value);
        }).onComplete(this, function() {
            loopRotation();
        });

        tween(SINE_EASE_OUT, duration * 0.25, 0, -1, function(value, time) {
            applyY(value);
        }).onComplete(this, function() {
            loopY();
        });

    }

/// Internal

    function loopY() {

        tween(SINE_EASE_IN_OUT, duration * 0.5, -1, 1, function(value, time) {
            applyY(value);
        }).onComplete(this, function() {
            tween(SINE_EASE_IN_OUT, duration * 0.5, 1, -1, function(value, time) {
                applyY(value);
            }).onComplete(this, function() {
                loopY();
            });
        });

    }

    function applyY(y:Float) {

        entity.transform.ty = y * amplitude;
        entity.transform.changedDirty = true;

    }

    function loopRotation() {

        tween(SINE_EASE_IN_OUT, duration * 1.0, -1, 1, function(value, time) {
            applyRotation(value);
        }).onComplete(this, function() {
            tween(SINE_EASE_IN_OUT, duration * 1.0, 1, -1, function(value, time) {
                applyRotation(value);
            }).onComplete(this, function() {
                loopRotation();
            });
        });

    }

    function applyRotation(r:Float) {

        entity.rotation = r * rotation;

    }

}
