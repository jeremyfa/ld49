package ld49;

import ceramic.Border;
import ceramic.Color;
import ceramic.Quad;

class PillarShape extends Quad {

    public function new(thickness:Float = 32, height:Float = 32) {

        super();

        color = 0xA12568;
        anchor(0.5, 0);
        size(thickness, height);

        var inner = new Quad();
        inner.color = Color.interpolate(0xA12568, Color.BLACK, 0.25);
        inner.depth = 1;
        inner.size(width * 0.5, height * 0.5);
        inner.anchor(0.5, 0.5);
        inner.pos(width * 0.5, height * 0.5);
        inner.rotation = 45;
        add(inner);

    }

}
