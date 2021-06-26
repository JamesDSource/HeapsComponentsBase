package hcb.hide;

import hrt.prefab.Context;
import hrt.prefab.Library;
import VectorMath;

#if hide
class CollisionBoxBody extends hrt.prefab.Object3D {

    private var mass: Float = 1;

    public function new(?parent) {
        super(parent);
        type = "collisionBoxBody";
    }

    public override function make(ctx:Context):Context {

        #if editor
        ctx = ctx.clone(this);
        var mesh = new h3d.scene.Mesh(h3d.prim.Cube.defaultUnitCube(), ctx.local3d);

		mesh.material.blendMode = Alpha;
        mesh.material.color.a = 0.1;

        ctx.local3d = mesh;
		ctx.local3d.name = name;
        #end

        updateInstance(ctx);
		return ctx;
    }

    public override function updateInstance( ctx: Context, ?propName : String ) {
		super.updateInstance(ctx, propName);
	}

    private override function save(): {} {
        var o: Dynamic = super.save();
        o.mass = mass;
        return o;
    }

    private override function load(v: Dynamic) {
        super.load(v);
        mass = v.mass;
    }

    #if editor

    static public function setDebugColor(color : Int, mat : h3d.mat.Material) {
		mat.color.setColor(color);
		var opaque = (color >>> 24) == 0xff;
		mat.shadows = false;

		if(opaque) {
			var alpha = mat.getPass("debuggeom_alpha");
			if(alpha != null)
				mat.removePass(alpha);
			mat.mainPass.setPassName("default");
		 	mat.mainPass.setBlendMode(None);
		 	mat.mainPass.depthWrite = true;
			mat.mainPass.culling = None;
		}
		else {
			mat.mainPass.setPassName("debuggeom");
			mat.mainPass.setBlendMode(Alpha);
			mat.mainPass.depthWrite = true;
			mat.mainPass.culling = Front;
			var alpha = mat.allocPass("debuggeom_alpha");
			alpha.setBlendMode(Alpha);
			alpha.culling = Back;
			alpha.depthWrite = false;
		}
	}

    public override function getHideProps() : hide.prefab.HideProps {
        return { icon : "square", name : "CollisionBoxBody" };
    }

    public override function edit(ctx : hide.prefab.EditContext) {
        super.edit(ctx);
        var props = new hide.Element(
            '
			<div class="group" name="Rigid Body">
				<dl>
					<dt>Mass</dt>
					<dd><input type="range" min="0" max="100" value="10" field="mass" /></dd>
				</dl>
			</div>
            '
		); 
        ctx.properties.add(props, this, function(propName) {
			ctx.onChange(this, propName);
		});
    }

    #end

    private static var _ = Library.register("CollisionBoxBody", CollisionBoxBody);
}
#end