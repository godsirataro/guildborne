"""Physical review lights attached to the authored lantern/ember locations."""
import bpy
def add_interior_lights():
 for obj in list(bpy.context.scene.objects):
  if obj.name.startswith('InteriorReviewLight_'):bpy.data.objects.remove(obj,do_unlink=True)
 for obj in list(bpy.context.scene.objects):
  if obj.type!='MESH':continue
  if obj.name.endswith('_LanternGlass'):
   power,color,radius=1300,(1,.78,.48),1.1
  elif obj.name.endswith('_ForgeEmber')or obj.name.endswith('_HearthEmber'):
   power,color,radius=120,(1,.30,.07),.5
  else:continue
  lamp=bpy.data.lights.new('InteriorReviewLight_'+obj.name,'POINT');lamp.energy=power;lamp.color=color;lamp.shadow_soft_size=radius
  light=bpy.data.objects.new(lamp.name,lamp);bpy.context.scene.collection.objects.link(light);light.location=obj.matrix_world.translation
  if obj.data.materials:
   material=obj.data.materials[0].copy();obj.data.materials[0]=material
   bs=material.node_tree.nodes.get('Principled BSDF')
   if bs:bs.inputs['Emission Color'].default_value=(*color,1);bs.inputs['Emission Strength'].default_value=3
