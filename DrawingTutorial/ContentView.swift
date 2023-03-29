//
//  ContentView.swift
//  DrawingTutorial
//
//  Created by Danjuma Nasiru on 21/01/2023.
//

import SwiftUI

struct SevenSidedshape : Shape{
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.maxX/4, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.maxX * 3/4, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.midY))
        path.addLine(to: CGPoint(x: rect.maxX * 3/4, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.midX, y: rect.midY))
        path.addLine(to: CGPoint(x: rect.maxX/4, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.minX, y: rect.midY))
        path.addLine(to: CGPoint(x: rect.maxX/4, y: rect.minY))
        return path
    }
}

struct Triangle: Shape{
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.midX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.minX, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.midX, y: rect.minY))
        
        return path
    }
}


struct Arc : Shape{
    var startAngle : Angle
    var endAngle : Angle
    var clockwise : Bool
    
    func path(in rect: CGRect) -> Path {
        let rotationAdjustment = Angle(degrees: 90)
        let modifiedStartAngle = startAngle - rotationAdjustment
        var modifiedEndAngle = endAngle - rotationAdjustment
        var path = Path()
        
        path.addArc(center: CGPoint(x: rect.midX, y: rect.midY), radius: rect.width / 2, startAngle: modifiedStartAngle, endAngle: modifiedEndAngle, clockwise: !clockwise)
        
        return path
    }
}

//by having our shape cnform to insettableshape, it can now use the strokeborder modifier which creates our stroke within the border and not half in half out like the regular stroke modifier.
//so here bcos our view will be reducing by a particular inset amount if strokeborder is used, we reduce our radius by that amount as well so everything still looks good
//also insettableshape conforms to shape protocol so you dont have to make your struct conform to both. just insettable is fine
struct InsetArc : InsettableShape{
    var startAngle : Angle
    var endAngle : Angle
    var clockwise : Bool
    var insetAmount = 0.0
    
    func path(in rect: CGRect) -> Path {
        let rotationAdjustment = Angle(degrees: 90)
        let modifiedStartAngle = startAngle - rotationAdjustment
        var modifiedEndAngle = endAngle - rotationAdjustment
        var path = Path()
        
        path.addArc(center: CGPoint(x: rect.midX, y: rect.midY), radius: rect.width / 2 - insetAmount, startAngle: modifiedStartAngle, endAngle: modifiedEndAngle, clockwise: !clockwise)
        
        return path
    }
    
    func inset(by amount: CGFloat) -> some InsettableShape {
        var arc = self
        arc.insetAmount = amount
        return arc
    }
}

//working with CGAffineTransform
struct Flower: Shape {
    // How much to move this petal away from the center
    var petalOffset: Double = -20
    
    // How wide to make each petal
    var petalWidth: Double = 100
    
    func path(in rect: CGRect) -> Path {
        // The path that will hold all petals
        var path = Path()
        
        // Count from 0 up to pi * 2, moving up pi / 8 each time
        for number in stride(from: 0, to: Double.pi * 2, by: Double.pi / 8){
            // rotate the petal by the current value of our loop
            let rotation = CGAffineTransform(rotationAngle: number)
            
            // move the petal to be at the center of our view
            let position = rotation.concatenating(CGAffineTransform(translationX: rect.width / 2, y: rect.height / 2))
            
            // create a path for this petal using our properties plus a fixed Y and height
            let originalPetal = Path(ellipseIn: CGRect(x: petalOffset, y: 0, width: petalWidth, height: rect.height / 2))
            
            // apply our rotation/position transformation to the petal
            let rotatedPetal = originalPetal.applying(position)
            
            // add it to our main path
            path.addPath(rotatedPetal)
            
            
        }
        // now send the main path back
        return path
    }
}

//when you're trying to render large/heavy graphics, use drawingGroup()
struct ColorCyclingCircle : View{
    var amount = 0.0
    var steps = 100

    var body: some View{
        ZStack{
            ForEach(0..<steps){value in
                Circle()
                    .inset(by: Double(value))
                    .strokeBorder(LinearGradient(
                        gradient: Gradient(colors: [
                            color(for: value, brightness: 1),
                            color(for: value, brightness: 0.5)
                        ]),
                        startPoint: .top,
                        endPoint: .bottom
                    ),
                    lineWidth: 2)
//                    .strokeBorder(color(for: value, brightness: 1), lineWidth: 2)
            }
        }.drawingGroup()
        //This tells SwiftUI it should render the contents of the view into an off-screen image before putting it back onto the screen as a single rendered output, which is significantly faster. Behind the scenes this is powered by Metal, which is Apple’s framework for working directly with the GPU for extremely fast graphics.
    }

    func color(for value: Int, brightness: Double) -> Color{
        var targetHue = Double(value) / Double(steps) + amount

        if targetHue > 1 {
            targetHue -= 1
        }

        return Color(hue: targetHue, saturation: 1, brightness: brightness)
    }
}




//struct ColorCyclingRectangle : View{
//    var amount = 0.0
//    var steps = 100
//    var startpoint: UnitPoint
//    var endPoint: UnitPoint
//
//    var animatableData: AnimatablePair<UnitPoint, UnitPoint>{
//        get{
//            AnimatablePair(startpoint, endPoint)
//        }
//        set{
//            startpoint = newValue.first
//            endPoint = newValue.second
//        }
//    }
//
//    var body: some View{
//        ZStack{
//            ForEach(0..<steps){value in
//                Circle()
//                    .inset(by: Double(value))
//                    .strokeBorder(LinearGradient(
//                        gradient: Gradient(colors: [
//                            color(for: value, brightness: 1),
//                            color(for: value, brightness: 0.5)
//                        ]),
//                        startPoint: startpoint,
//                        endPoint: endPoint
//                    ),
//                    lineWidth: 2)
////                    .strokeBorder(color(for: value, brightness: 1), lineWidth: 2)
//            }
//        }.drawingGroup()
//        //This tells SwiftUI it should render the contents of the view into an off-screen image before putting it back onto the screen as a single rendered output, which is significantly faster. Behind the scenes this is powered by Metal, which is Apple’s framework for working directly with the GPU for extremely fast graphics.
//    }
//
//    func color(for value: Int, brightness: Double) -> Color{
//        var targetHue = Double(value) / Double(steps) + amount
//
//        if targetHue > 1 {
//            targetHue -= 1
//        }
//
//        return Color(hue: targetHue, saturation: 1, brightness: brightness)
//    }
//}





//animate single value using animatableData computed property
struct Trapezoid: Shape {
    var insetAmount: Double
    
    var animatableData: Double {
        get { insetAmount }
        set { insetAmount = newValue }
    }

    func path(in rect: CGRect) -> Path {
        var path = Path()

        path.move(to: CGPoint(x: 0, y: rect.maxY))
        path.addLine(to: CGPoint(x: insetAmount, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.maxX - insetAmount, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
        path.addLine(to: CGPoint(x: 0, y: rect.maxY))

        return path
   }
}



//animate multiple value by having animatableData return type be animatablePair
struct Checkerboard: Shape {
    var rows: Int
    var columns: Int
    
//    var rows2: Int
//    var columns2 : Int

    var animatableData: AnimatablePair<Double,Double> {
        get {
           AnimatablePair(Double(rows), Double(columns))
        }

        set {
            rows = Int(newValue.first)
            columns = Int(newValue.second)
        }
    }
    
//    var animatableDataaaa: AnimatablePair<CGFloat, AnimatablePair<CGFloat, AnimatablePair<CGFloat, CGFloat>>> {
//        get {
//           AnimatablePair(Double(rows), AnimatablePair(Double(columns), AnimatablePair(Double(rows2),Double(columns2))))
//        }
//
//        set {
//            rows = Int(newValue.first)
//            columns = Int(newValue.second.first)
//            rows2 = Int(newValue.second.second.first)
//            columns2 = Int(newValue.second.second.second)
//        }
    //}
    
    
    
    func path(in rect: CGRect) -> Path {
        var path = Path()

        // figure out how big each row/column needs to be
        let rowSize = rect.height / Double(rows)
        let columnSize = rect.width / Double(columns)

        // loop over all rows and columns, making alternating squares colored
        for row in 0..<rows {
            for column in 0..<columns {
                if (row + column).isMultiple(of: 2) {
                    // this square should be colored; add a rectangle here
                    let startX = columnSize * Double(column)
                    let startY = rowSize * Double(row)

                    let rect = CGRect(x: startX, y: startY, width: columnSize, height: rowSize)
                    path.addRect(rect)
                }
            }
        }

        return path
    }
}





struct Arrow : Shape{
    
    var lineWidth : Int
    func path(in rect: CGRect) -> Path {
        var path = Path()
        
        path.move(to: CGPoint(x: rect.midX, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.midX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.maxX * 5 / 8, y: rect.maxY / 4))
        path.move(to: CGPoint(x: rect.midX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.maxX * 3 / 8, y: rect.maxY / 4))
        
        
        return path
    }
}






struct ContentView: View {
    
    @State private var arrowWidth = 10
    
    @State private var rows = 4
        @State private var columns = 4
    
    @State private var insetAmount = 50.0
    
    @State private var amount = 0.0
    
    @State private var colorCycle = 0.0
    
    @State private var petalOffset = -20.0
    @State private var petalWidth = 100.0
    var body: some View {
        
        
        
        
//        VStack(spacing: 50){
//            Arrow(lineWidth: arrowWidth).stroke(.red, style: StrokeStyle(lineWidth: CGFloat(arrowWidth), lineCap: .round, lineJoin: .round)).frame(width: 400, height: 400)
//
//            Button{
//                withAnimation(.easeIn.repeatCount(3, autoreverses: true).speed(0.3)){
//                    arrowWidth += 20
//                }
//            } label: {
//                Text("Tap me")
//            }.padding().background(.red).font(.title).foregroundColor(.black).clipShape(Capsule(style: .continuous))
//        }
        
        
        
        
        
//        VStack{
//
//            Trapezoid(insetAmount: insetAmount)
//                        .frame(width: 200, height: 100)
//                        .onTapGesture {
//                            withAnimation{insetAmount = Double.random(in: 10...90)}
//                        }
//
//            Checkerboard(rows: rows, columns: columns)
//                        .onTapGesture {
//                            withAnimation(.linear(duration: 3)) {
//                                rows = 8
//                                columns = 16
//                            }
//                        }
//        }
        
        
        
        
        
//        VStack {
//            ZStack {
//                Circle()
//                    .fill(Color(red: 1, green: 0, blue: 0))
//                    .frame(width: 200 * amount)
//                    .offset(x: -50, y: -80)
//                    .blendMode(.screen)
//
//                Circle()
//                    .fill(Color(red: 0, green: 1, blue: 0))
//                    .frame(width: 200 * amount)
//                    .offset(x: 50, y: -80)
//                    .blendMode(.screen)
//
//                Circle()
//                    .fill(Color(red: 0, green: 0, blue: 1))
//                    .frame(width: 200 * amount)
//                    .blendMode(.screen)
//            }
//            .frame(width: 300, height: 300)
//
//            Slider(value: $amount)
//                .padding()
//
//            Image("PaulHudson")
//                .resizable()
//                .scaledToFit()
//                .frame(width: 200, height: 200)
//                .saturation(amount)
//                .blur(radius: (1-amount) * 20)
//        }
//        .frame(maxWidth: .infinity, maxHeight: .infinity)
//        .background(.black)
//        .ignoresSafeArea()
        
        
        
        
        //        ZStack{
        //            Image("PaulHudson")
        //
        //            Rectangle()
        //                .fill(.red)
        //                .blendMode(.multiply)
        //        }.frame(width: 400, height: 500)
        //            .clipped()
        
        
        
        
        
                VStack {
                            ColorCyclingCircle(amount: colorCycle)
                                .frame(width: 300, height: 300)
        
                    Slider(value: $colorCycle)
                }
        
        
        
        
        //        ScrollView{
        //            VStack {
        //                Flower(petalOffset: petalOffset, petalWidth: petalWidth)
        //                    .fill(.red , style: FillStyle(eoFill: true))
        //                //     .stroke(.red, lineWidth: 1)
        //
        //                Text("Offset")
        //                Slider(value: $petalOffset, in: -40...40)
        //                    .padding([.horizontal, .bottom])
        //
        //                Text("Width")
        //                Slider(value: $petalWidth, in: 0...100)
        //                    .padding(.horizontal)
        //
        //                Text("coygggggg").frame(width: 300, height: 300).border(ImagePaint(image: Image("Example"), sourceRect: CGRect(x: 0, y: 0, width: 0.5, height: 1), scale: 0.1), width: 30)
        //
        //                Capsule()
        //                    .strokeBorder(ImagePaint(image: Image("Example"), sourceRect: CGRect(x: 0, y: 0, width: 1, height: 0.5), scale: 0.2), lineWidth: 30)
        //                    .frame(width: 300, height: 200)
        //
        //                Circle()
        //                    .fill(ImagePaint(image: Image("Example"), sourceRect: CGRect(x: 0, y: 0, width: 1, height: 1), scale: 0.2))
        //                    .frame(width: 300, height: 200)
        //            }
        //        }
        
        
        
        
        
        //        ScrollView{
        //            VStack{
        ////                Path{path in
        ////                    path.move(to: CGPoint(x: 200, y: 100))
        ////                    path.addLine(to: CGPoint(x: 100, y: 300))
        ////                    path.addLine(to: CGPoint(x: 300, y: 300))
        ////                    path.addLine(to: CGPoint(x: 200, y: 100))
        ////                    //this tells swiftui that this is the end of our path so connect it to the beginning of our path. Not needed if you use strokestyle with stroke modifier
        ////                    //path.closeSubpath()
        ////                }.stroke(.blue, style: StrokeStyle(lineWidth: 10, lineCap: .butt, lineJoin: .bevel))
        ////                //.stroke(LinearGradient(colors: [.red, .blue, .gray], startPoint: .top, endPoint: .bottom), lineWidth: 10.0)
        ////                //.fill(LinearGradient(colors: [.red, .blue, .gray], startPoint: .top, endPoint: .bottom))
        //
        //
        //
        //                Rectangle()
        //                    .stroke(LinearGradient(colors: [.blue, .red], startPoint: .topTrailing, endPoint: .bottomLeading), lineWidth: 4)
        //                    .frame(width: 150, height: 150)
        //                    .overlay(content: {Triangle().stroke(.red, style: StrokeStyle(lineWidth: 4, lineCap: .round, lineJoin: .round)).padding()})
        //
        //
        //                SevenSidedshape().stroke(.blue, style: StrokeStyle(lineWidth: 4, lineCap: .round, lineJoin: .round)).frame(width: 150, height: 150).overlay(content: {Text("😐").font(.title)}).padding()
        //
        //
        //                Triangle().stroke(.red, style: StrokeStyle(lineWidth: 10, lineCap: .round, lineJoin: .round))
        //                    .frame(width: 200, height: 100)
        //                    .padding()
        //
        //
        //
        //                Arc(startAngle: Angle(degrees: 0), endAngle: Angle(degrees: 110), clockwise: true).stroke(.cyan, lineWidth: 10).frame(width: 100, height: 100).padding()
        //
        //
        //                InsetArc(startAngle: .degrees(-90), endAngle: .degrees(90), clockwise: true).strokeBorder(.pink, lineWidth: 10).frame(width: 150, height: 100)
        //
        //
        //            }.frame(maxWidth: .infinity)
        //        }
        
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
