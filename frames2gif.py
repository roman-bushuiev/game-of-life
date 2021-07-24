from PIL import Image, ImageDraw


images = []

frames_path_prefix = './frames/frame'
gif_path = './output_gifs/new_gif.gif'
dead_color = (255, 255, 255)
alive_color = (0, 0, 0)
pixel_scale = 20

frame_number = 0
while True:
    try:
        with open(frames_path_prefix + str(frame_number)) as file:
            pixels = file.readlines()
        print('Processing frame', frame_number)
        frame_number += 1
    except IOError:
        break

    pixels = [[int(pixel) for pixel in pixels_row.rstrip('\n')] for pixels_row in pixels]

    image = Image.new('RGB', (len(pixels[0]) * pixel_scale, len(pixels) * pixel_scale), dead_color)
    for i in range(len(pixels)):
        for j in range(len(pixels[i])):
            color = alive_color if pixels[i][j] == 1 else dead_color
            for n in range(i * pixel_scale, (i + 1) * pixel_scale):
                for m in range(j * pixel_scale, (j + 1) * pixel_scale):
                    image.putpixel((m, n), color)

    images.append(image)

images[0].save(gif_path, save_all=True, append_images=images, optimize=False, duration=200, loop=0)
