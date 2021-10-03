package ld49;

import ceramic.Color;
import ceramic.Quad;
import ceramic.Shape;

using ceramic.Extensions;

#if plugin_nape
import ceramic.VisualNapePhysics;
import nape.geom.Vec2;
import nape.geom.Vec2List;
import nape.phys.Material;
import nape.shape.Polygon;
#end

class PlatformShape extends Shape {

    var steps:Int;

    var stepSize:Float;

    var teeth:Float;

    var thickness:Float;

    var walls:Float;

    var wallThickness:Float;

    public function new(steps:Int = 24, stepSize:Float = 32, teeth:Float = 16, thickness:Float = 24, walls:Float = 600, wallThickness:Float = 5) {

        super();

        anchor(0.5, 0.5);

        color = Color.WHITE;
        this.steps = steps;
        this.stepSize = stepSize;
        this.teeth = teeth;
        this.thickness = thickness;
        this.walls = walls;
        this.wallThickness = wallThickness;

        var points:Array<Float> = [];
        var idx = 0;

        points[idx++] = 0;
        points[idx++] = 0;

        points[idx++] = wallThickness;
        points[idx++] = 0;

        for (i in 0...steps) {

            points[idx++] = wallThickness + i * stepSize;
            points[idx++] = walls;

            points[idx++] = wallThickness + i * stepSize + stepSize * 0.5;
            points[idx++] = walls + teeth;

        }

        points[idx++] = wallThickness + steps * stepSize;
        points[idx++] = walls;

        points[idx++] = wallThickness + steps * stepSize;
        points[idx++] = 0;

        points[idx++] = wallThickness + steps * stepSize + wallThickness;
        points[idx++] = 0;

        points[idx++] = wallThickness + steps * stepSize + wallThickness;
        points[idx++] = walls + teeth + thickness;

        points[idx++] = 0;
        points[idx++] = walls + teeth + thickness;

        this.points = points;

        var top = new Quad();
        top.color = Color.WHITE;
        top.size(width, 5);
        top.depth = 10;
        top.anchor(0, 1);
        add(top);

    }

#if plugin_nape

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

            var points:Array<Float> = [];
            var idx = 0;

            points[idx++] = 0;
            points[idx++] = 0;

            points[idx++] = wallThickness;
            points[idx++] = 0;

            points[idx++] = wallThickness;
            points[idx++] = walls + teeth + thickness;

            points[idx++] = 0;
            points[idx++] = walls + teeth + thickness;

            addShape(points);

            var points:Array<Float> = [];
            var idx = 0;

            points[idx++] = wallThickness;
            points[idx++] = walls;

            points[idx++] = wallThickness + stepSize * 0.5;
            points[idx++] = walls + teeth;

            points[idx++] = wallThickness + stepSize * 0.5;
            points[idx++] = walls + teeth + thickness;

            points[idx++] = wallThickness;
            points[idx++] = walls + teeth + thickness;

            addShape(points);

            for (s in 0...steps-1) {

                var points:Array<Float> = [];
                var idx = 0;

                points[idx++] = wallThickness + s * stepSize + stepSize * 0.5;
                points[idx++] = walls + teeth;

                points[idx++] = wallThickness + s * stepSize + stepSize;
                points[idx++] = walls;

                points[idx++] = wallThickness + s * stepSize + stepSize * 1.5;
                points[idx++] = walls + teeth;

                points[idx++] = wallThickness + s * stepSize + stepSize * 1.5;
                points[idx++] = walls + teeth + thickness;

                points[idx++] = wallThickness + s * stepSize + stepSize * 0.5;
                points[idx++] = walls + teeth + thickness;

                addShape(points);

            }

            var points:Array<Float> = [];
            var idx = 0;

            points[idx++] = wallThickness + steps * stepSize - stepSize * 0.5;
            points[idx++] = walls + teeth;

            points[idx++] = wallThickness + steps * stepSize;
            points[idx++] = walls;

            points[idx++] = wallThickness + steps * stepSize;
            points[idx++] = walls + teeth + thickness;

            points[idx++] = wallThickness + steps * stepSize - stepSize * 0.5;
            points[idx++] = walls + teeth + thickness;

            addShape(points);

            var points:Array<Float> = [];
            var idx = 0;

            points[idx++] = wallThickness + steps * stepSize;
            points[idx++] = 0;

            points[idx++] = wallThickness + steps * stepSize + wallThickness;
            points[idx++] = 0;

            points[idx++] = wallThickness + steps * stepSize + wallThickness;
            points[idx++] = walls + teeth + thickness;

            points[idx++] = wallThickness + steps * stepSize;
            points[idx++] = walls + teeth + thickness;

            addShape(points);
        }

        material = Material.steel();
        material.elasticity = 0;

        return super.initNapePhysics(type, space, shape, shapes, material);

    }

#end

}
