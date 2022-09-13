//
//  SearchView.swift
//  AutoDB
//
//

import Foundation
import SwiftUI
import ImageIO
import SDWebImageSwiftUI
import Alamofire


class SearchObject: ObservableObject {
    @Published var modals = [String: [CheckModel]]()
    
    
    func getKey(key: String) -> [CheckModel] {
        
        let keyExists = self.modals[key] != nil
        if keyExists {
            return self.modals[key]!
        }
        
        else {
            return []
        }
    }
    
    func toggle(key: String, id: Int) {
        
        var lst = getKey(key: key)
        var v =  modals[key]!.first(where: {$0.id == id})

        //v.isSelected.toggle()
        
    }
}



struct SearchRow: View {
    @ObservedObject var search: SearchObject
    
    var body: some View {
        
        VStack {
            
            
            ScrollView(.horizontal, showsIndicators: false) {
                
                HStack {
            
                    ForEach(Array(search.modals.keys), id: \.self) { key in
                        
                        ForEach(binding(for: key), id: \.id) { $value in
                            
                            if value.isSelected {
                                HStack{
                                    Text(value.description)
                                        .font(.system(size: 20, design: .default))
            
                                    
                                    Button {
                                        print("Remove \(value.type) \(value.id)")
                                        value.isSelected.toggle()

                        
                                    } label: {
                                        Image(systemName: "minus.circle")
                                            .font(.system(size: 20, design: .default))

                                    }

                                }
                                .padding(.leading,10)
                                .padding(.trailing,10)
                                .padding(.top, 4)
                                .padding(.bottom,4)
                                .background(Capsule().strokeBorder(.blue, lineWidth: 1))

                            }
                    
                        }
                        
                    }
                }
            
            }
            .padding(.leading, 1)
            .padding(.trailing,2)
            
        }
        
        


    }
    
    private func binding(for key: String) -> Binding<[CheckModel]> {
        return Binding(get: {
            return search.modals[key] ?? []
        }, set: {
            search.modals[key] = $0
        })
    }
    
}


struct CheckModel: Codable, Identifiable, Hashable, Equatable {
    var id: Int
    var type: String
    var description: String
    var isSelected: Bool
}

struct CheckCellView: View {
    @Binding var cell: CheckModel
    
    var body: some View {
        
        HStack {
            Image(systemName: cell.isSelected ? "checkmark.square" : "square")
                .foregroundColor(.blue)
                .onTapGesture {
                    cell.isSelected.toggle()
                }
                
            Text(cell.description)
        }.frame(maxWidth:.infinity, alignment: .leading)
        
    }
    
    
    
}

struct TestView: View {
    var label: String
    
    @Binding var cells: [CheckModel]
    @Binding var updated: Bool
    
    @State private var multiSelection = Set<Int>()
    @Environment(\.editMode) private var editMode

        
    var body: some View {
        VStack {
            List($cells, selection: $multiSelection) { $cell in
                Text(cell.description)
            }
            
            .onChange(of: editMode!.wrappedValue, perform: { value in
              if value.isEditing {
                 // Entering edit mode (e.g. 'Edit' tapped)
              } else {
                 // Leaving edit mode (e.g. 'Done' tapped)
                  
                  //for var cell in cells {
                      
                     // if multiSelection.contains(cell.id){
                      //    cell.isSelected.toggle()

                     // }
                //  }
                  
                 self.updated.toggle()
              }
            })
            .navigationTitle(label)
            .toolbar { EditButton() }
        }
        Text("\(multiSelection.count) selections")
    }

}


struct CheckRow: View {
    var label: String
    
    @Binding var cells: [CheckModel]
    @Binding var updated: Bool
        
    var body: some View {
        
        VStack {
            
            List($cells, id: \.id) { $cell in
                
                CheckCellView(cell: $cell)
                    .onChange(of: cell) { _ in
                        updated.toggle()
                    }
            }
            

        }.navigationTitle(label)
    }
    
}



struct LocationRow: View {
    
    @State var postcode = ""
    let range = [CheckModel(id: 0, type: "distance", description: "Nationwide", isSelected: true),
                 CheckModel(id: 10, type: "distance",description: "10 Miles", isSelected: false),
                 CheckModel(id: 25, type: "distance", description: "20 Miles", isSelected: false),
                 CheckModel(id: 50, type: "distance", description: "50 miles", isSelected: false)]
    @State var rangeSelect = 0
    
    
    var body: some View {
        VStack(spacing: 10) {
            
            TextField("Postcode", text: $postcode)
                .padding()
                .keyboardType(.decimalPad)
                .background(
                    RoundedRectangle(cornerRadius: 5, style: .continuous)
                    .strokeBorder(.blue, lineWidth: 1))

            
            Picker("Range", selection: $rangeSelect) {
                ForEach(range, id: \.id) {
                    Text($0.description)
                }
            }
            .pickerStyle(.menu)
        }

        .navigationTitle("Location")
        .padding()
    }
}

struct MileageRow: View {
    
    @State private var mileage = 400000.0
    @State private var isEditing = false
    
    
    var body: some View {
        VStack(spacing: 20) {
            
            HStack {
                Slider(
                    value: $mileage,
                    in: 0...400000,
                    onEditingChanged: { editing in
                        isEditing = editing
                    }
                )
                
            }

            Text("\(Int(mileage)) miles")
                .foregroundColor(isEditing ? .red : .blue)
        }
        .navigationTitle("Mileage")
        .padding()
    }
}

struct PriceRow: View {
    
    @State private var priceMax = 400000.0
    @State private var priceMin = 0.0
    
    // define min & max value
    @State var minValue: Float = 0.0
    @State var maxValue: Float = Float(UIScreen.main.bounds.width - 50.0)
    @State private var isEditing = false
    
    

    
    var body: some View {

        // setup slider view
        VStack {
            HStack {
                Text("$\(Int(priceMin))")
                    .offset(x: 5, y: 20)
                    .frame(width: 100, height: 30, alignment: .leading)
                    .foregroundColor(.black)
                
                Spacer()
                
                Text("$\(Int(priceMax))")
                    .offset(x: -5, y: 20)
                    .frame(width: 100, height: 30, alignment: .trailing)
                    .foregroundColor(.black)
            }
            
            ZStack(alignment: Alignment(horizontal: .leading, vertical: .center), content: {
                Capsule()
                    .fill(.gray.opacity(25))
                    .frame(width: CGFloat((UIScreen.main.bounds.width - 50) + 10), height: 4)
                
                Capsule()
                    .fill(.blue.opacity(25))
                    .offset(x: CGFloat(self.minValue))
                    .frame(width: CGFloat((self.maxValue) - self.minValue), height: 4)
                
                Circle()
                    .fill(.white)
                    .frame(width: 30, height: 30)
                    .offset(x: CGFloat(self.minValue))
                    .gesture(DragGesture().onChanged({ (value) in
                        if value.location.x > 8 && value.location.x <= (UIScreen.main.bounds.width - 50) &&
                            value.location.x < CGFloat(self.maxValue - 10) {
                            self.minValue = Float(value.location.x - 8)
                            
                            self.priceMin = 400000.0 * Double(self.minValue)/UIScreen.main.bounds.width

                        }
                    }))
                    .shadow(radius: 5)
                
                Text(String(format: "%.0f", (CGFloat(self.minValue) / (UIScreen.main.bounds.width - 50)) * 100))
                    .offset(x: CGFloat(self.minValue))
                    .frame(width: 30, height: 30, alignment: .center)
                    .foregroundColor(.black)
                        
                Circle()
                    .fill(.white)
                    .frame(width: 30, height: 30)
                    .offset(x: CGFloat(self.maxValue - 18))
                    .gesture(DragGesture().onChanged({ (value) in
                        if value.location.x - 8 <= (UIScreen.main.bounds.width - 50) &&  value.location.x > CGFloat(self.minValue + 50) {
                            self.maxValue = Float(value.location.x - 8)
                            
                            self.priceMax = 400000.0 * Double(self.maxValue)/UIScreen.main.bounds.width

                        }
                    }))
                    .shadow(radius: 5)

                
                Text(String(format: "%.0f", (CGFloat(self.maxValue) / (UIScreen.main.bounds.width - 50)) * 100))
                    .offset(x: CGFloat(self.maxValue - 18))
                    .frame(width: 30, height: 30, alignment: .center)
                    .foregroundColor(.black)
            })
            .padding()
        }
  
        .navigationTitle("Price")
        .padding()
    }
}


struct YearRow: View {
    @ObservedObject var search: SearchObject
    
    
    @State var start = 1980
    @State var end = 2022

    @State var startRange = [Int]()
    @State var endRange = [Int]()

    
    var body: some View {
        
        VStack {
            
            VStack {
                Text("Start Year")
                    .font(.headline)
                    .bold()
                
                Picker("Start Year", selection: $start) {
                    ForEach(1980...end, id: \.self) {
                        Text(String($0))
                    }
                }
                .pickerStyle(InlinePickerStyle())
                .onChange(of: start) { newValue in
                    search.modals["start_year"] = [CheckModel(id: start, type: "year", description: "\(start) min", isSelected: true)]
                }
            }
            
            
            VStack {
                Text("End Year")
                    .font(.headline)
                    .bold()
                
                Picker("End Year", selection: $end) {
                    ForEach(start...2022, id: \.self) {
                        Text(String($0))
                    }
                }
                .pickerStyle(InlinePickerStyle())
                .onChange(of: end) { newValue in
                    search.modals["end_year"] = [CheckModel(id: start, type: "year", description: "\(end) max", isSelected: true)]
                }
            }
        
        
        }
        .onAppear(perform: {
            if search.modals["start_year"] != nil {
                start = search.modals["start_year"]![0].id
            }
            
            if search.modals["end_year"] != nil {
                start = search.modals["end_year"]![0].id
            }
            
        })
        
    }
    

}


struct FilterView: View {
    
    @Binding var components: [String: String]
    @ObservedObject var search: SearchObject


    @State private var mileage = 400000.0
    @State private var isEditing = false
    
    @State var postcode = ""
    let range = [CheckModel(id: 0, type: "distance", description: "Nationwide", isSelected: true),
                 CheckModel(id: 10, type: "distance",description: "10 Miles", isSelected: false),
                 CheckModel(id: 25, type: "distance", description: "20 Miles", isSelected: false),
                 CheckModel(id: 50, type: "distance", description: "50 miles", isSelected: false)]
    @State var rangeSelect = 0
    
    
    @State var updated = false

    
    var body: some View {
        

        VStack {
            List {
                
                Group {
                    
                    
                    NavigationLink {
                        LocationRow()
                    } label: {
                        VStack {
                            Text("Location")
                        }
                    }
                    
                    NavigationLink {
                        YearRow(search: search)
                    } label: {
                        VStack {
                            Text("Year")
                        }
                    }
                    

                    NavigationLink {
                        MileageRow()
                    } label: {
                        VStack {
                            Text("Mileage")
                        }
                    }
                    
                    
                    NavigationLink {
                        PriceRow()
                    } label: {
                        VStack {
                            Text("Price")
                        }
                    }
                    
                }

        
                NavigationLink {
                    CheckRow(label: "Make", cells: binding(for: "make"), updated: $updated)
                } label: {
                    VStack {
                        Text("Makes")
                    }
                }
                
                NavigationLink {
                    CheckRow(label: "Body", cells: binding(for: "body"), updated: $updated)
                } label: {
                    VStack {
                        Text("Body")
                    }
                }
                
                NavigationLink {
                    CheckRow(label: "Color", cells: binding(for: "color"), updated: $updated)
                } label: {
                    VStack {
                        Text("Color")
                    }
                }
                
                NavigationLink {
                    CheckRow(label: "Fuel", cells: binding(for: "fuel"), updated: $updated)
                } label: {
                    VStack {
                        Text("Fuel")
                    }
                }
                
                
                NavigationLink {
                    CheckRow(label: "Transmission", cells: binding(for: "transmission"), updated: $updated)
                } label: {
                    VStack {
                        Text("Transmission")
                    }
                }
                
                NavigationLink {
                    CheckRow(label: "Drivetrain", cells: binding(for: "drivetrain"), updated: $updated)
                } label: {
                    VStack {
                        Text("Drivetrain")
                    }
                }
                
                
                NavigationLink {
                    CheckRow(label: "Condition", cells: binding(for: "condition"), updated: $updated)
                } label: {
                    VStack {
                        Text("Condition")
                    }
                }
                
                

                
            }
        }

        

        .navigationTitle("Filter")
        .onChange(of: updated){ _ in
            print("Updated Checklist")
            self.processQuery()
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(.white)
        .edgesIgnoringSafeArea(.all)
    }
    
    func processQuery() -> Void {
        
        
        let selectMakes = search.modals["make"]!.filter { cell in
            return cell.isSelected
        }.map{$0.description}.joined(separator: "/")
        
        let selectBodys = search.modals["body"]!.filter { cell in
            return cell.isSelected
        }.map{String($0.id)}.joined(separator: "_")
        
        let selectTransmission = search.modals["transmission"]!.filter { cell in
            return cell.isSelected
        }.map{String($0.id)}.joined(separator: "_")
        
        let selectDrivetrains = search.modals["drivetrain"]!.filter { cell in
            return cell.isSelected
        }.map{String($0.id)}.joined(separator: "_")
        
        
        let selectFuels = search.modals["fuel"]!.filter { cell in
            return cell.isSelected
        }.map{String($0.id)}.joined(separator: "_")
        
        
        self.components["path"] = selectMakes

        
        if !selectBodys.isEmpty {
            //params.append(URLQueryItem(name: "bodyCode", value: selectBodys))
            self.components["bodyCode"] = selectBodys
        }
        
        if !selectTransmission.isEmpty {
            //params.append(URLQueryItem(name: "transmissionCode", value: selectTransmission))
            self.components["transmissionCode"] = selectTransmission
        }
        
        if !selectDrivetrains.isEmpty {
            //params.append(URLQueryItem(name: "drivetrainCode", value: selectDrivetrains))
            self.components["drivetrainCode"] = selectDrivetrains
        }
                          
        if !selectFuels.isEmpty {
            //params.append(URLQueryItem(name: "fuelCode", value: selectFuels))
            self.components["fuelCode"] = selectFuels
        }
                          
        
        
        var params = [URLQueryItem]()

        
        var urlComponents = URLComponents()
        urlComponents.scheme = "http"
        urlComponents.host = "localhost"
        urlComponents.path = "/auto/search/\(selectMakes)"
        urlComponents.queryItems = params
        print(urlComponents.url?.absoluteString)

        
        //
        //var urlComps = URLComponents(string: "\(encoded_url)")!
        //urlComps.queryItems = queryItems
        //let result = urlComps.url!

        
    }
    
    private func binding(for key: String) -> Binding<[CheckModel]> {
        return Binding(get: {
            return search.modals[key] ?? []
        }, set: {
            search.modals[key] = $0
        })
    }
}


/**
struct FilterView2: View {
    
    @Binding var components: [String: String]
    @ObservedObject var search: SearchObject


    @State private var mileage = 400000.0
    @State private var isEditing = false
    
    @State var postcode = ""
    let range = [CheckModel(id: 0, type: "distance", description: "Nationwide", isSelected: true),
                 CheckModel(id: 10, type: "distance",description: "10 Miles", isSelected: false),
                 CheckModel(id: 25, type: "distance", description: "20 Miles", isSelected: false),
                 CheckModel(id: 50, type: "distance", description: "50 miles", isSelected: false)]
    @State var rangeSelect = 0
    
    
    @State var updated = false

    
    var body: some View {
        

        
        List {
            
            Collapsible(
                label: {
                    Text("Location")
                    
                },
                content: {
                    HStack {
                        VStack(spacing: 10) {
                            
                            TextField("Postcode", text: $postcode)
                                .padding()
                                .keyboardType(.decimalPad)
                                .background(
                                    RoundedRectangle(cornerRadius: 5, style: .continuous)
                                    .strokeBorder(.blue, lineWidth: 1))

                            
                            Picker("Range", selection: $rangeSelect) {
                                ForEach(range, id: \.id) {
                                    Text($0.description)
                                }
                            }
                            .pickerStyle(.automatic)
                            
                        }

                    }
                    .frame(maxWidth: .infinity)
                }
            )
            //.padding(.top, 100)

            
            Collapsible(
                label: {
                    Text("Mileage")
                    
                },
                content: {
                    VStack(spacing: 1) {
                        
                        HStack {
                            Slider(
                                value: $mileage,
                                in: 0...400000,
                                onEditingChanged: { editing in
                                    isEditing = editing
                                }
                            )
                            
                        }

                        
                        Text("\(Int(mileage))")
                            .foregroundColor(isEditing ? .red : .blue)
                    }
                    
                    .frame(maxWidth: .infinity)
                }
            )
            
            
            Collapsible(
                label: {
                    Text("Make")
                    
                },
                content: {
                    HStack {
                        
                        CheckRow(cells: binding(for: "make"), updated: $updated)

                    }
                    .frame(maxWidth: .infinity)
                }
            )

            
            Collapsible(
                label: {
                    Text("Body")
                    
                },
                content: {
                    HStack {
                        CheckRow(cells: binding(for: "body"), updated: $updated)

                    }
                    .frame(maxWidth: .infinity)
                }
            )
            
            Collapsible(
                label: {
                    Text("Fuel")
                    
                },
                content: {
                    VStack {
                        CheckRow(cells: binding(for: "fuel"), updated: $updated)

                    }
                    .frame(maxWidth: .infinity)
                }
            )
            
            
            Collapsible(
                label: {
                    Text("Drivetrain")
                    
                },
                content: {
                    HStack {
                        CheckRow(cells: binding(for: "drivetrain"), updated: $updated)

                    }
                    .frame(maxWidth: .infinity)
                }
            )
            
            Collapsible(
                label: {
                    Text("Transmission")
                    
                },
                content: {
                    HStack {
                        CheckRow(cells: binding(for: "transmission"), updated: $updated)

                    }
                    .frame(maxWidth: .infinity)
                }
            )
            
        }
        .onChange(of: updated){ _ in
            print("Updated Checklist")
            self.processQuery()
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(.white)
        .edgesIgnoringSafeArea(.all)
    }
    
    func processQuery() -> Void {
        
        
        let selectMakes = search.modals["make"]!.filter { cell in
            return cell.isSelected
        }.map{$0.description}.joined(separator: "/")
        
        let selectBodys = search.modals["body"]!.filter { cell in
            return cell.isSelected
        }.map{String($0.id)}.joined(separator: "_")
        
        let selectTransmission = search.modals["transmission"]!.filter { cell in
            return cell.isSelected
        }.map{String($0.id)}.joined(separator: "_")
        
        let selectDrivetrains = search.modals["drivetrain"]!.filter { cell in
            return cell.isSelected
        }.map{String($0.id)}.joined(separator: "_")
        
        
        let selectFuels = search.modals["fuel"]!.filter { cell in
            return cell.isSelected
        }.map{String($0.id)}.joined(separator: "_")
        
        
        self.components["path"] = selectMakes

        
        if !selectBodys.isEmpty {
            //params.append(URLQueryItem(name: "bodyCode", value: selectBodys))
            self.components["bodyCode"] = selectBodys
        }
        
        if !selectTransmission.isEmpty {
            //params.append(URLQueryItem(name: "transmissionCode", value: selectTransmission))
            self.components["transmissionCode"] = selectTransmission
        }
        
        if !selectDrivetrains.isEmpty {
            //params.append(URLQueryItem(name: "drivetrainCode", value: selectDrivetrains))
            self.components["drivetrainCode"] = selectDrivetrains
        }
                          
        if !selectFuels.isEmpty {
            //params.append(URLQueryItem(name: "fuelCode", value: selectFuels))
            self.components["fuelCode"] = selectFuels
        }
                          
        
        
        var params = [URLQueryItem]()

        
        var urlComponents = URLComponents()
        urlComponents.scheme = "http"
        urlComponents.host = "localhost"
        urlComponents.path = "/auto/search/\(selectMakes)"
        urlComponents.queryItems = params
        print(urlComponents.url?.absoluteString)

        
        //
        //var urlComps = URLComponents(string: "\(encoded_url)")!
        //urlComps.queryItems = queryItems
        //let result = urlComps.url!

        
    }
    
    private func binding(for key: String) -> Binding<[CheckModel]> {
        return Binding(get: {
            return search.modals[key] ?? []
        }, set: {
            search.modals[key] = $0
        })
    }
}
**/

enum Direction {
    // enumeration definition goes here
    case ASC
    case DESC
}


struct SortView: View {
    
    @Binding var components: [String:String]

    
    @State private var selection: CheckModel?
    @State var direction = Direction.ASC
    @State var order = "price"
    
    var sort = [
        CheckModel(id: 0, type: "sort", description: "Relevance", isSelected: true),
        CheckModel(id: 1, type: "sort", description: "Price Low to High", isSelected: false),
        CheckModel(id: 2, type: "sort", description: "Price High to Low", isSelected: false),
        CheckModel(id: 3, type: "sort", description: "Year Low to High", isSelected: false),
        CheckModel(id: 4, type: "sort", description: "Year High to Low", isSelected: false),
        CheckModel(id: 5, type: "sort", description: "Mileage Low to High", isSelected: false),
        CheckModel(id: 6, type: "sort", description: "Mileage High to Low", isSelected: false)
    ]

    
    var body: some View {
        
        VStack(alignment: .leading) {
                
                List(selection: $selection) {
                    
                    ForEach(self.sort, id: \.id) { option in

                        HStack {
                            
                            Image(systemName: option == self.selection ? "checkmark.circle" : "circle")
                                    .foregroundColor(.blue)
                            

                            VStack(alignment: .leading) {
                                Text("\(option.description)")
                            }
                   
                            Spacer()
                        }
                        .contentShape(Rectangle())
                        .frame(height: 50)
                        .onTapGesture {
                            self.selection = option
                            self.processSelection(option: option)
                        }
                    }
                    
                }
                .background(.white)
                

            Spacer()
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(.white)
        .edgesIgnoringSafeArea(.all)
    }
    
    
    func processSelection(option: CheckModel) {
        
        switch option.id {
            case 0:
                self.order = "id"
                self.direction = Direction.ASC
            case 1:
                self.order = "price"
                self.direction = Direction.ASC
            case 2:
                self.order = "price"
                self.direction = Direction.DESC
            case 3:
                self.order = "year"
                self.direction = Direction.ASC
            case 4:
                self.order = "year"
                self.direction = Direction.DESC
            case 5:
                self.order = "mileage"
                self.direction = Direction.ASC
            case 6:
                self.order = "mileage"
                self.direction = Direction.DESC
            case 7:
                self.order = "created";
                self.direction = Direction.ASC;
            default:
                self.order = "id";
                self.direction = Direction.ASC;
        }
        
        self.components["sortBy"] = self.order
        self.components["sortDirection"] = self.direction == Direction.ASC ? "0" : "1"

    }
}

struct ResultView: View {
    @EnvironmentObject var meta: Meta
    
    
    @Binding var components: [String:String]
    @ObservedObject var search: SearchObject

    @State var params = [URLQueryItem]()
    
    @State var columns = [
        GridItem(.adaptive(minimum: 275, maximum: 400))
    ]
    
    @StateObject private var dataSource = ContentDataSource<Auto>()

    var body: some View {
        
        ScrollView {
            
            LazyVGrid(columns: columns, spacing: 20) {
                ForEach(dataSource.items, id: \.id) { auto in
                    
                    NavigationLink {
                        AutoView(auto: auto)
                        
                    } label: {
                        AutoCard(auto: auto)
                            .frame(width: 300, height: 320, alignment: .top)

                        
                        .onAppear(perform: {
                            if !self.dataSource.endOfList {
                                if self.dataSource.shouldLoadMore(item: auto) {
                                    self.dataSource.fetch(path: meta.query, params: params)

                                }
                            }
                        })
                    }
                    
                }
                
                if dataSource.isLoadingPage {
                    ProgressView()
                }

            }
            .padding(.top, 25)

        }
        
        .onChange(of: components) { _ in
            self.processQuery()
        }
        .onAppear {
            self.processQuery()
            //self.dataSource.fetch(path: "auto/search/\(query)")
            
            self.dataSource.fetch(path: meta.query, params: params)
        }
        
    }
    
    func processQuery() -> Void {
        
        var params = [URLQueryItem]()

        if self.components.keys.contains( "bodyCode") {
            params.append(URLQueryItem(name: "bodyCode", value: self.components["bodyCode"]))
        }
        
        if self.components.keys.contains( "transmissionCode") {
            params.append(URLQueryItem(name: "transmissionCode", value: self.components["transmissionCode"]))
        }
        
        if self.components.keys.contains( "drivetrainCode") {
            params.append(URLQueryItem(name: "drivetrainCode", value: self.components["drivetrainCode"] ))
        }
                          
        if self.components.keys.contains( "fuelCode") {
            params.append(URLQueryItem(name: "fuelCode", value: self.components["fuelCode"]))
        }
        
        if self.components.keys.contains( "sortBy") {
            params.append(URLQueryItem(name: "sortBy", value: self.components["sortBy"]))
        }
        
        if self.components.keys.contains( "sortDirection") {
            params.append(URLQueryItem(name: "sortDirection", value: self.components["sortDirection"]))
        }
        
        //if self.components.keys.contains( "path") {
       //     path = self.components["path"]!
       // }
             
        self.params = params
        self.dataSource.reset()
        self.dataSource.fetch(path: meta.query, params: params)


    }
    
}

struct SearchItem: Hashable, Identifiable {
    var id: Self {self}
    var name: String
    var children: [CheckModel]? = []

}




struct SearchView: View {
    
    let width = UIScreen.main.bounds.width
    let height = UIScreen.main.bounds.height
        
    @State var components = [String: String]()
    @State var modal = [String: [CheckModel]]()
    
    @State var makeModel = [CheckModel]()
    @State var bodyModel = [CheckModel]()
    @State var fuelModel = [CheckModel]()
    @State var colorModel = [CheckModel]()
    @State var driveModel = [CheckModel]()
    @State var transmissionModel = [CheckModel]()
    @State var conditionModel = [CheckModel]()
    @State var conditions = [
        CheckModel(id: 1, type: "condition", description: "New", isSelected: false),
        CheckModel(id: 2, type: "condition", description: "Used", isSelected: false),
        CheckModel(id: 3, type: "condition", description: "Manufacturer Certified", isSelected: false),
        CheckModel(id: 4, type: "condition", description: "Third-Party Certified", isSelected: false)
    ]
    
    
    @State var showFilter = false
    @State var showSort = false
    @State var title = "Search"
    
    
    @StateObject var search = SearchObject()
    @State var test = [SearchItem]()


    
    var body: some View {
        

        let drag = DragGesture()
            .onEnded {
                if $0.translation.width < -100 {
                    withAnimation {
                        self.showFilter = false
                        self.showSort = false
                    }
                }
            }
        
            
            VStack {
                
                SearchRow(search: search)
                
                GeometryReader { geometry in
                    
                    
                    ZStack(alignment: .leading) {
                        
                        ResultView(components: $components, search: search)
                            .frame(width: geometry.size.width, height: geometry.size.height)
                            .offset(x: self.showFilter || self.showSort ? geometry.size.width/1.5 : 0)
                            .disabled(self.showFilter || self.showSort ? true : false)
                        
                        if self.showFilter {
                            
        
                            FilterView(components: $components, search: search)
                                .frame(width: geometry.size.width)
                                .transition(.move(edge: .leading))
                        }
                        
                        if self.showSort {
                            
                            
                            SortView(components: $components)
                                .frame(width: geometry.size.width)
                                .transition(.move(edge: .trailing))
                        }


                    }
                    .gesture(drag)
                }
                
            }
            .navigationBarTitle("\(self.title)", displayMode: .inline)
            .navigationBarItems(leading: (
                
                HStack {
                    Button(action: {
                        
                        
                        if showSort {
                            self.showSort = false
                        }
                        
                        withAnimation {
                            
                            self.showFilter.toggle()
                        }
                    }) {
                        Image(systemName: "line.3.horizontal.decrease.circle")
                            .imageScale(.large)
                    }
                }), trailing:
                    
                    HStack {
                        Button(action: {
                            
                            if showFilter {
                                self.showFilter = false
                            }
                            
                            withAnimation {
                                self.showSort.toggle()
                            }
                        }) {
                            Image(systemName: "arrow.up.arrow.down.circle")
                                .imageScale(.large)
                        }
                        
                    }


            )
        
        
        .onAppear {
            self.buildFuel()
            self.buildBody()
            self.buildMakes()
            self.buildDrivetrain()
            self.buildTransmission()
            self.buildConditions()
            self.buildColors()
        }
    }
    
    
    
    func buildTransmission() {
        let URL = "http://10.81.1.123:8080/auto/transmission/all"
        NetworkManager.shared.getRequest(of: [Transmission].self, url: URL) { (result) in
            switch result {
            case .success(let values):
                DispatchQueue.main.async {
                    for value in values {
                        let data = CheckModel(id: value.id, type:"transmission", description: value.description, isSelected: false)
                        self.transmissionModel.append(data)
                        
                    }
                    
                    search.modals["transmission"] = self.transmissionModel
                    
                }
            case .failure(let error):
                DispatchQueue.main.async {
                    print("Error")
                    
                }
            }
        }
    }
    
    
    
    func buildDrivetrain() {
        let URL = "http://10.81.1.123:8080/auto/drivetrain/all"
        NetworkManager.shared.getRequest(of: [Drivetrain].self, url: URL) { (result) in
            switch result {
            case .success(let values):
                DispatchQueue.main.async {
                    for value in values {
                        let data = CheckModel(id: value.id, type:"drivetrain", description: value.name, isSelected: false)
                        self.driveModel.append(data)
                    }
                    
                    search.modals["drivetrain"] = self.driveModel

                    
                }
            case .failure(let error):
                DispatchQueue.main.async {
                    print("Error")
                    
                }
            }
        }
    }
    
    
    func buildFuel() {
        let URL = "http://10.81.1.123:8080/auto/fuel/all"
        NetworkManager.shared.getRequest(of: [Fuel].self, url: URL) { (result) in
            switch result {
            case .success(let values):
                DispatchQueue.main.async {
                    for value in values {
                        let data = CheckModel(id: value.id, type: "fuel", description: value.type, isSelected: false)
                        self.fuelModel.append(data)
        
                    }
                    
                    search.modals["fuel"] = fuelModel

                    
                }
            case .failure(let error):
                DispatchQueue.main.async {
                    print("Error")
                    
                }
            }
        }
    }

    
    func buildBody() {
        let URL = "http://10.81.1.123:8080/body/type/all"
        NetworkManager.shared.getRequest(of: [BodyType].self, url: URL) { (result) in
            switch result {
            case .success(let values):
                DispatchQueue.main.async {
                    var temp = SearchItem(name: "Body")

                    
                    for value in values {
                        let data = CheckModel(id: value.id,  type: "body", description: value.type, isSelected: false)
                        self.bodyModel.append(data)
                        

                    }
                    
                    search.modals["body"] = self.bodyModel

                    temp.children = self.bodyModel
                    test.append(temp)
                    
                }
            case .failure(let error):
                DispatchQueue.main.async {
                    print("Error")
                    
                }
            }
        }
    }

    
    func buildMakes() {
        let URL = "http://10.81.1.123:8080/make/all"
        NetworkManager.shared.getRequest(of: [Make].self, url: URL) { (result) in
            switch result {
            case .success(let values):
                DispatchQueue.main.async {
                    
                    var temp = SearchItem(name: "Make")
                    
                    
                
                    
                    for value in values {
                        let data = CheckModel(id: value.id, type: "make", description: value.name, isSelected: false)
                        self.makeModel.append(data)

                    }
                
                    temp.children = self.makeModel
                    test.append(temp)
                    
                    search.modals["make"] = self.makeModel

                    
                }
            case .failure(let error):
                DispatchQueue.main.async {
                    print("Error")
                    
                }
            }
        }
    }

    
    func buildColors() {
        let URL = "http://10.81.1.123:8080/auto/color/all"
        NetworkManager.shared.getRequest(of: [Make].self, url: URL) { (result) in
            switch result {
            case .success(let values):
                DispatchQueue.main.async {
                    
                    var temp = SearchItem(name: "Make")
                    
                    
                
                    
                    for value in values {
                        let data = CheckModel(id: value.id, type: "color", description: value.name, isSelected: false)
                        self.colorModel.append(data)

                    }
                
                    temp.children = self.colorModel
                    test.append(temp)
                    
                    search.modals["color"] = self.colorModel

                    
                }
            case .failure(let error):
                DispatchQueue.main.async {
                    print("Error")
                    
                }
            }
        }
    }
    
    func buildConditions() {
        
        search.modals["condition"] = self.conditions
        
    }
    
}
