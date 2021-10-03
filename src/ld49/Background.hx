package ld49;

import ceramic.Color;
import ceramic.Layer;
import ceramic.Quad;
import ceramic.Transform;

class Background extends Layer {

    var itemColor:Color = Color.interpolate(0x3B185F, Color.BLACK, 0.2);

    var allShapes:Array<Quad> = [];

    var bgTransform:Transform = new Transform();

    public function new() {

        super();

        transparent = false;
        color = 0x2A0944;

    }

    public function update(delta:Float) {

        bgTransform.tx = (bgTransform.tx + delta * 20) % 48;
        bgTransform.ty = (bgTransform.ty + delta * 20) % 48;
        bgTransform.changedDirty = true;

    }

    public function createShapes() {

        while (allShapes.length > 0) {
            allShapes.pop().destroy();
        }

        var size = 48.0;
        var step = 48.0;
        var y = -size;

        while (y <= height + step) {
            var x = -size;

            while (x <= width + step) {
                var quad = new Quad();
                quad.size(size, size);
                quad.rotation = 45;
                quad.color = itemColor;
                quad.anchor(0.5, 0.5);
                quad.pos(x, y);
                quad.scale(0.75);
                quad.transform = bgTransform;
                add(quad);

                x += step;
            }

            y += step;
        }

    }

}