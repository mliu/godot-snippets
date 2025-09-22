# Importing a custom bitmap font

- Click on the import tab and then import it as Font data. You need to map out the text in decimals

# Fixing blurry font

- Click on the import tab and check "Multichannel signed distance fields" (Make sure to reimport)

# Pixel perfect display settings

https://docs.godotengine.org/en/stable/tutorials/rendering/multiple_resolutions.html

# How to mask?

You need to enable clip children.

# Position/Vector2 tween not working?

Sometimes cursor suggests you tween an individual property like position.y. You need to tween the entire position and do vector manipulation

# AudioStreamRandomizer not playing when calling set_streamAttribution 4.0 International (CC BY 4.0)?

You need to make sure it has streams in the streams array, even if they're 0

# Figuring out whether a mouse click is in a Polygon shape

Context: The polygon shape and camera are both within a scene in a subviewport

Findings
- The shapes position is relative to the SCENE (world coordinates)
- The click event position is relative to the CAMERA (screen coordinates)
- I realized I needed to transform the click event position from screen coordinates to world coordinates
  
I manually calcualted the global mouse position before realizing you can use get_global_mouse_position() instead to get the position relative to the scene. But here's the calculation:

var transformed_point = global_point + camera.position - Vector2(get_viewport_rect().size.x / 2, get_viewport_rect().size.y / 2)
var relative_point = transformed_point - camera.position
var actual_point = camera.position + relative_point / camera.zoom

Although one thing I learned about camera.zoom:
- Converting from camera coords to world coords requires multiplying or dividing by camera.zoom. How do you tell when to do either?
- If converting from screen -> world coords, you need to divide. If you're converting the other way, you need to multiply.
- Another way to think about it: Higher zoom = relative mouse position offset should technically go down when converting to world coordinates (because you're covering less pixels)

Once you have the world coordinates point, the rest is trivial.
