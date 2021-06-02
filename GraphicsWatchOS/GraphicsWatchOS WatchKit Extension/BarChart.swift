
//
//  BarChart.swift
//  GraphicsWatchOS WatchKit Extension
//
//  Created by Juliano Vaz on 01/06/21.
//

import SwiftUI


struct ChartData {
    var label: String
    var value: Double
}

let chartDataSet = [
    ChartData(label: "January 2021", value: 340.32),
    ChartData(label: "February 2021", value: 250.0),
    ChartData(label: "March 2021", value: 430.22),
    ChartData(label: "April 2021", value: 350.0),
    ChartData(label: "May 2021", value: 450.0),
    ChartData(label: "June 2021", value: 380.0),
    ChartData(label: "July 2021", value: 365.98)
]

struct BarChartCell: View {
    
    var value: Double
    var barColor: Color
    
    var body: some View {
        RoundedRectangle(cornerRadius: 5)
            .fill(barColor)
            .scaleEffect(CGSize(width: 1, height: value), anchor: .bottom)
        
    }
}

struct BarChart: View {
    
    @State private var currentValue = ""
    @State private var currentLabel = ""
    @State private var touchLocation: CGFloat = -1
    
    var title: String
    var legend: String
    var barColor: Color
    var data: [ChartData]
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(title)
                .bold()
                .font(.caption)
            Text("Current value: \(currentValue)")
                .font(.headline)
            //Geomety Reader
            GeometryReader { geometry in
                VStack {
                    HStack { //celulas (cada barra)
                        ForEach(0..<data.count, id: \.self) { i in
                            BarChartCell(value: normalizedValue(index: i), barColor: barColor)
                                .opacity(barIsTouched(index: i) ? 1 : 0.7)
                                .scaleEffect(barIsTouched(index: i) ? CGSize(width: 1.05, height: 1) : CGSize(width: 1, height: 1), anchor: .bottom)
                                .animation(.spring())
                                .padding(.top)
                        }
                    }
                    
                    .gesture(DragGesture(minimumDistance: 0)
                                .onChanged({ position in
                                    let touchPosition = position.location.x/geometry.frame(in: .local).width
                                    touchLocation = touchPosition
                                    updateCurrentValue()
                                })
                                
                                .onEnded({ _ in
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                        withAnimation(Animation.easeOut(duration: 0.5)) {
                                            resetValues()
                                        }
                                    }
                                })
                    )
                    
                    //mostra legenda se barra ainda n foi tocada
                    if currentLabel.isEmpty {
                        Text(legend)
                            .bold()
                            .foregroundColor(.black)
                            .padding(5)
                            .background(RoundedRectangle(cornerRadius: 5).foregroundColor(.white).shadow(radius: 3))
                    } else {
                        //label da barra tocada no momento
                        Text(currentLabel)
                            .bold()
                            .foregroundColor(.black)
                            .padding(5)
                            .background(RoundedRectangle(cornerRadius: 5).foregroundColor(.white).shadow(radius: 3))
                            .offset(x: labelOffset(in: geometry.frame(in: .local).width))
                            .animation(.easeIn)
                    }
                }
            }
            
            
        }
        .padding()
    }
    
    func normalizedValue(index: Int) -> Double {
        //Esta função atribui um valor de 1 ao valor máximo em nosso array e, em seguida, obtém a proporção de cada valor restante para o nosso máximo.  Portanto, em uma matriz de [30, 50, 100, 75, 60], 100 será retornado como 1, enquanto 30 será retornado como 30/100, 50 será retornado como 50/100 e assim por diante.
        var allValues: [Double]    {
            var values = [Double]()
            for data in data {
                values.append(data.value)
            }
            return values
        }
        guard let max = allValues.max() else {
            return 1
        }
        if max != 0 {
            return Double(data[index].value)/Double(max)
        } else {
            return 1
        }
    }
    
    func barIsTouched(index: Int) -> Bool {
        touchLocation > CGFloat(index)/CGFloat(data.count) && touchLocation < CGFloat(index+1)/CGFloat(data.count)
    }
    
    func updateCurrentValue()    {
        let index = Int(touchLocation * CGFloat(data.count)) //A função updateCurrentValue usa o valor de touchLocation para encontrar o índice do valor em nossa matriz de dados . Portanto, para um touchLocation de 0,5, nosso índice será o índice intermediário na matriz de dados
        guard index < data.count && index >= 0 else { //Precisamos ter cuidado aqui para ter certeza de que o índice não vai além do primeiro ou último índice em nosso array de dados , então usamos uma instrução guard para manter isso sob controle.
            currentValue = ""
            currentLabel = ""
            return
        }
        currentValue = "\(data[index].value)"
        currentLabel = data[index].label
    }
    
    func resetValues() {
        touchLocation = -1
        currentValue  =  ""
        currentLabel = ""
    }
    
    func labelOffset(in width: CGFloat) -> CGFloat {
        let currentIndex = Int(touchLocation * CGFloat(data.count))
        guard currentIndex < data.count && currentIndex >= 0 else {
            return 0
        }
        let cellWidth = width / CGFloat(data.count)
        let actualWidth = width -    cellWidth
        let position = cellWidth * CGFloat(currentIndex) - actualWidth/2
        return position
    }
}

struct BarChart_Previews: PreviewProvider {
    static var previews: some View {
        BarChart(title: "Monthly Sales", legend: "EUR", barColor: .blue, data: chartDataSet)
    }
}

