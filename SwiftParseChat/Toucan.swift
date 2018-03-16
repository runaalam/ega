// Toucan.swift
//
// Copyright (c) 2014 Gavin Bunney, Bunney Apps (http://bunney.net.au)
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

import UIKit

/**
Toucan - Fabulous Image Processing in Swift.

The Toucan class provides two methods of interaction - either through an instance, wrapping an single image,
or through the static functions, providing an image for each invocation.

This allows for some flexible usage. Using static methods when you need a single operation:
let resizedImage = Toucan.resize(myImage, size: CGSize(width: 100, height: 150))

Or create an instance for easy method chaining:
let resizedAndMaskedImage = Toucan(withImage: myImage).resize(CGSize(width: 100, height: 150)).maskWithEllipse().image
*/
open class Toucan : NSObject {
    
    open var image : UIImage
    
    public init(image withImage: UIImage) {
        self.image = withImage
    }

    // MARK: - Resize
    
    /**
    Resize the contained image to the specified size. Depending on what fitMode is supplied, the image
    may be clipped, cropped or scaled. @see documentation on FitMode.
    
    The current image on this toucan instance is replaced with the resized image.
    
    :param: size    Size to resize the image to
    :param: fitMode How to handle the image resizing process
    
    :returns: Self, allowing method chaining
    */
    open func resize(_ size: CGSize, fitMode: Toucan.Resize.FitMode = .clip) -> Toucan {
        self.image = Toucan.Resize.resizeImage(self.image, size: size, fitMode: fitMode)
        return self
    }
    
    /**
    Resize the contained image to the specified size by resizing the image to fit
    within the width and height boundaries without cropping or scaling the image.
    
    The current image on this toucan instance is replaced with the resized image.
    
    :param: size    Size to resize the image to
    
    :returns: Self, allowing method chaining
    */
    @objc
    open func resizeByClipping(_ size: CGSize) -> Toucan {
        self.image = Toucan.Resize.resizeImage(self.image, size: size, fitMode: .clip)
        return self
    }
    
    /**
    Resize the contained image to the specified size by resizing the image to fill the
    width and height boundaries and crops any excess image data.
    The resulting image will match the width and height constraints without scaling the image.
    
    The current image on this toucan instance is replaced with the resized image.
    
    :param: size    Size to resize the image to
    
    :returns: Self, allowing method chaining
    */
    @objc
    open func resizeByCropping(_ size: CGSize) -> Toucan {
        self.image = Toucan.Resize.resizeImage(self.image, size: size, fitMode: .crop)
        return self
    }
    
    /**
    Resize the contained image to the specified size by scaling the image to fit the
    constraining dimensions exactly.
    
    The current image on this toucan instance is replaced with the resized image.
    
    :param: size    Size to resize the image to
    
    :returns: Self, allowing method chaining
    */
    @objc
    open func resizeByScaling(_ size: CGSize) -> Toucan {
        self.image = Toucan.Resize.resizeImage(self.image, size: size, fitMode: .scale)
        return self
    }
    
    /**
    Container struct for all things Resize related
    */
    public struct Resize {
        
        /**
        FitMode drives the resizing process to determine what to do with an image to
        make it fit the given size bounds.
        
        - Clip:  Resizes the image to fit within the width and height boundaries without cropping or scaling the image.
        
        - Crop:  Resizes the image to fill the width and height boundaries and crops any excess image data.
        
        - Scale: Scales the image to fit the constraining dimensions exactly.
        */
        public enum FitMode {
            /**
            Resizes the image to fit within the width and height boundaries without cropping or scaling the image.
            The resulting image is assured to match one of the constraining dimensions, while
            the other dimension is altered to maintain the same aspect ratio of the input image.
            */
            case clip
            
            /**
            Resizes the image to fill the width and height boundaries and crops any excess image data.
            The resulting image will match the width and height constraints without scaling the image.
            */
            case crop
            
            /**
            Scales the image to fit the constraining dimensions exactly.
            */
            case scale
        }
        
        /**
        Resize an image to the specified size. Depending on what fitMode is supplied, the image
        may be clipped, cropped or scaled. @see documentation on FitMode.
        
        :param: image   Image to Resize
        :param: size    Size to resize the image to
        :param: fitMode How to handle the image resizing process
        
        :returns: Resized image
        */
        public static func resizeImage(_ image: UIImage, size: CGSize, fitMode: FitMode = .clip) -> UIImage {
            
            let imgRef = Util.CGImageWithCorrectOrientation(image)
            let originalWidth  = CGFloat(imgRef.width)
            let originalHeight = CGFloat(imgRef.height)
            let widthRatio = size.width / originalWidth
            let heightRatio = size.height / originalHeight
            
            let scaleRatio = widthRatio > heightRatio ? widthRatio : heightRatio
            
            let resizedImageBounds = CGRect(x: 0, y: 0, width: round(originalWidth * scaleRatio), height: round(originalHeight * scaleRatio))
            let resizedImage = Util.drawImageInBounds(image, bounds: resizedImageBounds)
            
            switch (fitMode) {
            case .clip:
                return resizedImage
            case .crop:
                let croppedRect = CGRect(x: (resizedImage.size.width - size.width) / 2,
                    y: (resizedImage.size.height - size.height) / 2,
                    width: size.width, height: size.height)
                return Util.croppedImageWithRect(resizedImage, rect: croppedRect)
            case .scale:
                return Util.drawImageInBounds(resizedImage, bounds: CGRect(x: 0, y: 0, width: size.width, height: size.height))
            }
        }
    }

    // MARK: - Mask

    /**
    Mask the contained image with another image mask.
    Note that the areas in the original image that correspond to the black areas of the mask
    show through in the resulting image. The areas that correspond to the white areas of
    the mask aren’t painted. The areas that correspond to the gray areas in the mask are painted
    using an intermediate alpha value that’s equal to 1 minus the image mask sample value.
    
    :param: maskImage Image Mask to apply to the Image
    
    :returns: Self, allowing method chaining
    */
    open func maskWithImage(#maskImage : UIImage)  -> Toucan {
        self.image = Toucan.Mask.maskImageWithImage(self.image, maskImage: maskImage)
        return self
    }
    
    /**
    Mask the contained image with an ellipse.
    Allows specifying an additional border to draw on the clipped image.
    For a circle, ensure the image width and height are equal!
    
    :param: borderWidth Optional width of the border to apply - default 0
    :param: borderColor Optional color of the border - default White
    
    :returns: Self, allowing method chaining
    */
    open func maskWithEllipse(_ borderWidth: CGFloat = 0, borderColor: UIColor = UIColor.white) -> Toucan {
        self.image = Toucan.Mask.maskImageWithEllipse(self.image, borderWidth: borderWidth, borderColor: borderColor)
        return self
    }
    
    /**
    Mask the contained image with a rounded rectangle border.
    Allows specifying an additional border to draw on the clipped image.
    
    :param: cornerRadius Radius of the rounded rect corners
    :param: borderWidth  Optional width of border to apply - default 0
    :param: borderColor  Optional color of the border - default White
    
    :returns: Self, allowing method chaining
    */
    open func maskWithRoundedRect(#cornerRadius: CGFloat, _ borderWidth: CGFloat = 0, borderColor: UIColor = UIColor.white) -> Toucan {
        self.image = Toucan.Mask.maskImageWithRoundedRect(self.image, cornerRadius: cornerRadius, borderWidth: borderWidth, borderColor: borderColor)
        return self
    }
    
    /**
    Container struct for all things Mask related
    */
    public struct Mask {
        
        /**
        Mask the given image with another image mask.
        Note that the areas in the original image that correspond to the black areas of the mask
        show through in the resulting image. The areas that correspond to the white areas of
        the mask aren’t painted. The areas that correspond to the gray areas in the mask are painted
        using an intermediate alpha value that’s equal to 1 minus the image mask sample value.
        
        :param: image     Image to apply the mask to
        :param: maskImage Image Mask to apply to the Image
        
        :returns: Masked image
        */
        public static func maskImageWithImage(_ image: UIImage, maskImage: UIImage) -> UIImage {
            
            let imgRef = Util.CGImageWithCorrectOrientation(image)
            let maskRef = maskImage.cgImage
            
            let mask = CGImage(maskWidth: (maskRef?.width)!,
                height: (maskRef?.height)!,
                bitsPerComponent: (maskRef?.bitsPerComponent)!,
                bitsPerPixel: (maskRef?.bitsPerPixel)!,
                bytesPerRow: (maskRef?.bytesPerRow)!,
                provider: (maskRef?.dataProvider!)!, decode: nil, shouldInterpolate: false);
            
            let masked = imgRef.masking(mask!);
            
            return Util.drawImageWithClosure(size: image.size) { (size: CGSize, context: CGContext) -> () in
                
                // need to flip the transform matrix, CoreGraphics has (0,0) in lower left when drawing image
                CGContextScaleCTM(context, 1, -1)
                CGContextTranslateCTM(context, 0, -size.height)
                
                CGContextDrawImage(context, CGRect(x: 0, y: 0, width: size.width, height: size.height), masked);
            }
        }
        
        /**
        Mask the given image with an ellipse.
        Allows specifying an additional border to draw on the clipped image.
        For a circle, ensure the image width and height are equal!
        
        :param: image       Image to apply the mask to
        :param: borderWidth Optional width of the border to apply - default 0
        :param: borderColor Optional color of the border - default White
        
        :returns: Masked image
        */
        public static func maskImageWithEllipse(_ image: UIImage,
            borderWidth: CGFloat = 0, borderColor: UIColor = UIColor.white) -> UIImage {
                
                let imgRef = Util.CGImageWithCorrectOrientation(image)
                let size = CGSize(width: CGFloat(imgRef.width) / image.scale, height: CGFloat(imgRef.height) / image.scale)
                
                return Util.drawImageWithClosure(size: size) { (size: CGSize, context: CGContext) -> () in
                    
                    let rect = CGRect(x: 0, y: 0, width: size.width, height: size.height)
                    
                    CGContextAddEllipseInRect(context, rect)
                    CGContextClip(context)
                    image.drawInRect(rect)
                    
                    if (borderWidth > 0) {
                        CGContextSetStrokeColorWithColor(context, borderColor.CGColor);
                        CGContextSetLineCap(context, kCGLineCapButt);
                        CGContextSetLineWidth(context, borderWidth);
                        CGContextAddEllipseInRect(context, CGRect(x: borderWidth / 2,
                            y: borderWidth / 2,
                            width: size.width - borderWidth,
                            height: size.height - borderWidth));
                        CGContextStrokePath(context);
                    }
                }
        }
        
        /**
        Mask the given image with a rounded rectangle border.
        Allows specifying an additional border to draw on the clipped image.
        
        :param: image        Image to apply the mask to
        :param: cornerRadius Radius of the rounded rect corners
        :param: borderWidth  Optional width of border to apply - default 0
        :param: borderColor  Optional color of the border - default White
        
        :returns: Masked image
        */
        public static func maskImageWithRoundedRect(_ image: UIImage, cornerRadius: CGFloat,
            borderWidth: CGFloat = 0, borderColor: UIColor = UIColor.white) -> UIImage {
                
                let imgRef = Util.CGImageWithCorrectOrientation(image)
                let size = CGSize(width: CGFloat(imgRef.width) / image.scale, height: CGFloat(imgRef.height) / image.scale)
                
                return Util.drawImageWithClosure(size: size) { (size: CGSize, context: CGContext) -> () in
                    
                    let rect = CGRect(x: 0, y: 0, width: size.width, height: size.height)
                    
                    UIBezierPath(roundedRect:rect, cornerRadius: cornerRadius).addClip()
                    image.drawInRect(rect)
                    
                    if (borderWidth > 0) {
                        CGContextSetStrokeColorWithColor(context, borderColor.CGColor);
                        CGContextSetLineCap(context, kCGLineCapButt);
                        CGContextSetLineWidth(context, borderWidth);
                        
                        let borderRect = CGRect(x: 0, y: 0,
                            width: size.width, height: size.height)
                        
                        let borderPath = UIBezierPath(roundedRect: borderRect, cornerRadius: cornerRadius)
                        borderPath.lineWidth = borderWidth * 2
                        borderPath.stroke()
                    }
                }
        }
    }
    
    // MARK: - Layer
    
    /**
    Overlay an image ontop of the current image.
    
    :param: image        Image to be on the bottom layer
    :param: overlayImage Image to be on the top layer, i.e. drawn on top of image
    :param: overlayFrame Frame of the overlay image

    :returns: Self, allowing method chaining
    */
    open func layerWithOverlayImage(_ overlayImage: UIImage, overlayFrame: CGRect) -> Toucan {
        self.image = Toucan.Layer.overlayImage(self.image, overlayImage:overlayImage, overlayFrame:overlayFrame)
        return self
    }
    
    /**
    Container struct for all things Layer related
    */
    public struct Layer {
        
        /**
        Overlay the given image into a new layout ontop of the image.
        
        :param: image        Image to be on the bottom layer
        :param: overlayImage Image to be on the top layer, i.e. drawn on top of image
        :param: overlayFrame Frame of the overlay image
        
        :returns: Masked image
        */
        public static func overlayImage(_ image: UIImage, overlayImage: UIImage, overlayFrame: CGRect) -> UIImage {

            let imgRef = Util.CGImageWithCorrectOrientation(image)
            let overlayRef = Util.CGImageWithCorrectOrientation(overlayImage)
            let size = CGSize(width: CGFloat(imgRef.width) / image.scale, height: CGFloat(imgRef.height) / image.scale)
            
            return Util.drawImageWithClosure(size: size) { (size: CGSize, context: CGContext) -> () in
                
                let rect = CGRect(x: 0, y: 0, width: size.width, height: size.height)
                
                image.drawInRect(rect)
                overlayImage.drawInRect(overlayFrame);
            }
        }
    }
    
    /**
    Container struct for internally used utility functions.
    */
    internal struct Util {
        
        /**
        Get the CGImage of the image with the orientation fixed up based on EXF data.
        This helps to normalise input images to always be the correct orientation when performing
        other core graphics tasks on the image.
        
        :param: image Image to create CGImageRef for
        
        :returns: CGImageRef with rotated/transformed image context
        */
        static func CGImageWithCorrectOrientation(_ image : UIImage) -> CGImage {
            
            if (image.imageOrientation == UIImageOrientation.up) {
                return image.cgImage!
            }
            
            UIGraphicsBeginImageContextWithOptions(image.size, false, 0)
            
            let context = UIGraphicsGetCurrentContext()
            
            // TODO - handle other image orientations / mirrored states
            switch (image.imageOrientation) {
            case UIImageOrientation.right:
                context?.rotate(by: CGFloat(90 * M_PI/180))
                break
            case UIImageOrientation.left:
                context?.rotate(by: CGFloat(-90 * M_PI/180))
                break
            case UIImageOrientation.down:
                context?.rotate(by: CGFloat(M_PI))
                break
            default:
                break
            }
            
            image.draw(at: CGPoint(x: 0, y: 0));
            
            let cgImage = context?.makeImage();
            UIGraphicsEndImageContext();
            
            return cgImage!;
        }
        
        /**
        Draw the image within the given bounds (i.e. resizes)
        
        :param: image  Image to draw within the given bounds
        :param: bounds Bounds to draw the image within
        
        :returns: Resized image within bounds
        */
        static func drawImageInBounds(_ image: UIImage, bounds : CGRect) -> UIImage {
            return drawImageWithClosure(size: bounds.size) { (size: CGSize, context: CGContext) -> () in
                image.drawInRect(bounds)
            };
        }
        
        /**
        Crap the image within the given rect (i.e. resizes and crops)
        
        :param: image Image to clip within the given rect bounds
        :param: rect  Bounds to draw the image within
        
        :returns: Resized and cropped image
        */
        static func croppedImageWithRect(_ image: UIImage, rect: CGRect) -> UIImage {
            return drawImageWithClosure(size: rect.size) { (size: CGSize, context: CGContext) -> () in
                let drawRect = CGRectMake(-rect.origin.x, -rect.origin.y, image.size.width, image.size.height)
                CGContextClipToRect(context, CGRectMake(0, 0, rect.size.width, rect.size.height))
                image.drawInRect(drawRect)
            };
        }
        
        /**
        Closure wrapper around image context - setting up, ending and grabbing the image from the context.
        
        :param: size    Size of the graphics context to create
        :param: closure Closure of magic to run in a new context
        
        :returns: Image pulled from the end of the closure
        */
        static func drawImageWithClosure(#size: CGSize!, _ closure: (_ size: CGSize, _ context: CGContext) -> ()) -> UIImage {
            UIGraphicsBeginImageContextWithOptions(size, false, 0)
            closure(size: size, context: UIGraphicsGetCurrentContext())
            let image : UIImage = UIGraphicsGetImageFromCurrentImageContext()!
            UIGraphicsEndImageContext()
            return image
        }
    }
}