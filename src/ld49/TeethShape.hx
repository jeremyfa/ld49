package ld49;

import ceramic.Color;
import ceramic.Line;
import ceramic.Shape;

using ceramic.Extensions;

#if plugin_nape
import ceramic.VisualNapePhysics;
import nape.geom.Vec2;
import nape.geom.Vec2List;
import nape.phys.Material;
import nape.shape.Polygon;
#end

class TeethShape extends Shape {

    public var steps(default, null):Int;

    var stepSize:Float;

    var teeth:Float;

    public var thickness(default, null):Float;

    var line:Line;

    override function set_color(color:Color):Color {
        super.set_color(color);
        if (line != null) {
            line.color = Color.interpolate(color, Color.WHITE, 0.5);
        }
        return color;
    }

    public function new(steps:Int = 4, stepSize:Float = 32, teeth:Float = 16, thickness:Float = 0) {

        super();

        anchor(0.5, 0.5);

        if (thickness <= 0)
            thickness = 0.0001;

        color = Color.WHITE;
        this.steps = steps;
        this.stepSize = stepSize;
        this.teeth = teeth;
        this.thickness = thickness;

        var points:Array<Float> = [];
        var idx = 0;
        var i = 0;
        while (i < steps) {

            points[idx++] = i * stepSize;
            points[idx++] = teeth;

            points[idx++] = i * stepSize + stepSize * 0.5;
            points[idx++] = 0;

            i++;

        }

        points[idx++] = steps * stepSize;
        points[idx++] = teeth;

        points[idx++] = steps * stepSize;
        points[idx++] = teeth + thickness;

        i = steps - 1;
        while (i >= 0) {

            points[idx++] = i * stepSize + stepSize * 0.5;
            points[idx++] = teeth + thickness + teeth;

            points[idx++] = i * stepSize;
            points[idx++] = teeth + thickness;

            i--;

        }

        this.points = points;

        line = new Line();
        line.color = Color.WHITE;
        line.thickness = 2;
        line.points = points.concat([points[0], points[1]]);
        line.loop = true;
        line.depth = 2;
        add(line);

    }

#if plugin_nape

    static var _material = new Material(0,0.03,0.1,4,0.0001);

    override function initNapePhysics(
        type:ceramic.NapePhysicsBodyType,
        ?space:nape.space.Space,
        ?shape:nape.shape.Shape,
        ?shapes:Array<nape.shape.Shape>,
        ?material:nape.phys.Material
    ):VisualNapePhysics {

        if (nape != null) {
            nape.destroy();
            nape = null;
        }

        if (contentDirty) {
            computeContent();
        }

        inline function addShape(points:Array<Float>) {

            var shapePoints = new Vec2List();
            var len = points.length;
            var i = 0;
            var w2 = width * 0.5;
            var h2 = height * 0.5;
            while (i < len - 1) {
                var iB = i + 1;
                shapePoints.push(Vec2.weak(
                    points.unsafeGet(i) - w2,
                    points.unsafeGet(iB) - h2
                ));
                i += 2;
            }
            shape = new Polygon(shapePoints);
            shapes.push(shape);

        }

        if (shape == null && (shapes == null || shapes.length == 0)) {

            shapes = [];

            for (s in 0...steps) {

                var points:Array<Float> = [];
                var idx = 0;

                points[idx++] = s * stepSize;
                points[idx++] = teeth;

                points[idx++] = s * stepSize + stepSize * 0.5;
                points[idx++] = 0;

                points[idx++] = s * stepSize + stepSize;
                points[idx++] = teeth;

                points[idx++] = s * stepSize + stepSize;
                points[idx++] = teeth + thickness;

                points[idx++] = s * stepSize + stepSize * 0.5;
                points[idx++] = teeth + thickness + teeth;

                points[idx++] = s * stepSize;
                points[idx++] = teeth + thickness;

                addShape(points);

            }
        }

        material = _material;

        var result = super.initNapePhysics(type, space, shape, shapes, material);

        //nape.body.mass *= 2;

        return result;

    }

#end

}
