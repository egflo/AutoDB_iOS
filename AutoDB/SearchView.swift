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
    @Published var components: [String:String]
    @Published var updated = false
    
    init(query: String = "all") {
        self.modals = [String: [CheckModel]]()
        self.updated = false
        self.components = [String:String]()
    }
    
    
    func getKey(key: String) -> [CheckModel] {
        let keyExists = self.modals[key] != nil
        if keyExists {
            return self.modals[key]!
        }
        
        else {
            return []
        }
    }
    
    
    func toggle(key: String, id: Int) -> Bool{
        
        let keyExists = self.modals[key] != nil
        if keyExists {
            var index = self.modals[key]!.firstIndex(where: {$0.id == id})
            
            if var unwrapped = index {
                self.modals[key]![unwrapped].isSelected.toggle()
                
                return true
                
            } else {
                return false
            }
            
        }
        
        else {
            return false
        }
    }
    
    func resetKey(key: String) {
        
        let keyExists = self.modals[key] != nil
        if keyExists {
            for (index, _) in self.modals[key]!.enumerated() {
                self.modals[key]![index].isSelected = false
            }
        }
        
        else {
            return
        }
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

struct CheckRow: View {
    @EnvironmentObject var search: SearchObject
    
    var label: String
    @Binding var cells: [CheckModel]
    @Binding var updated: Bool
        
    var body: some View {
        
        VStack {
            List(search.modals[label.lowercased()] ?? [], id: \.id) {cell in
                
                HStack {
                    Image(systemName: cell.isSelected ? "checkmark.square" : "square")
                        .foregroundColor(.blue)
                        .onTapGesture {
                            search.toggle(key: label.lowercased(), id: cell.id)
                            search.updated.toggle()
                        }
                        
                    Text(cell.description)
                }.frame(maxWidth:.infinity, alignment: .leading)
            }
            
        }
        .navigationTitle(label)
    }
    
}


struct SearchRow: View {
    @EnvironmentObject var search: SearchObject

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



struct LocationRow: View {
    @EnvironmentObject var search: SearchObject

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
    @EnvironmentObject var search: SearchObject

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
    @EnvironmentObject var search: SearchObject

    @State private var priceMax = 400000.0
    @State private var priceMin = 0.0
    
    // define min & max value
    @State var minValue: Float = 0.0
    @State var maxValue: Float = Float(UIScreen.main.bounds.width - 50.0)
    @State private var isEditing = false
    
    
    var body: some View {

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
    @EnvironmentObject var search: SearchObject

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
    @EnvironmentObject var search: SearchObject

    @State private var mileage = 400000.0
    @State private var isEditing = false
    
    @State var postcode = ""
    let range = [CheckModel(id: 0, type: "distance", description: "Nationwide", isSelected: true),
                 CheckModel(id: 10, type: "distance",description: "10 Miles", isSelected: false),
                 CheckModel(id: 25, type: "distance", description: "20 Miles", isSelected: false),
                 CheckModel(id: 50, type: "distance", description: "50 miles", isSelected: false)]
    @State var rangeSelect = 0
    
    
    var body: some View {
        
        VStack {
            
            
            List {
                Group {
                    
                    NavigationLink {
                        LocationRow()
                            .environmentObject(search)

                    } label: {
                        VStack {
                            Text("Location")
                        }
                    }
                    
                    NavigationLink {
                        YearRow()
                            .environmentObject(search)

                    } label: {
                        VStack {
                            Text("Year")
                        }
                    }
                    

                    NavigationLink {
                        MileageRow()
                            .environmentObject(search)

                    } label: {
                        VStack {
                            Text("Mileage")
                        }
                    }
                    
                    
                    NavigationLink {
                        PriceRow()
                            .environmentObject(search)

                    } label: {
                        VStack {
                            Text("Price")
                        }
                    }
                    
                }

        
                NavigationLink {
                    CheckRow(label: "Make", cells: binding(for: "make"), updated: $search.updated)
                        .environmentObject(search)

                } label: {
                    VStack {
                        Text("Makes")
                    }
                }
                
                NavigationLink {
                    CheckRow(label: "Body", cells: binding(for: "body"), updated: $search.updated)
                        .environmentObject(search)

                } label: {
                    VStack {
                        Text("Body")
                    }
                }
                
                NavigationLink {
                    CheckRow(label: "Color", cells: binding(for: "color"), updated: $search.updated)
                        .environmentObject(search)

                } label: {
                    VStack {
                        Text("Color")
                    }
                }
                
                NavigationLink {
                    CheckRow(label: "Fuel", cells: binding(for: "fuel"), updated: $search.updated)
                        .environmentObject(search)

                } label: {
                    VStack {
                        Text("Fuel")
                    }
                }
                
                
                NavigationLink {
                    CheckRow(label: "Transmission", cells: binding(for: "transmission"), updated: $search.updated)
                        .environmentObject(search)

                } label: {
                    VStack {
                        Text("Transmission")
                    }
                }
                
                NavigationLink {
                    CheckRow(label: "Drivetrain", cells: binding(for: "drivetrain"), updated: $search.updated)
                        .environmentObject(search)

                } label: {
                    VStack {
                        Text("Drivetrain")
                    }
                }
                
                
                NavigationLink {
                    CheckRow(label: "Condition", cells: binding(for: "condition"), updated: $search.updated)
                        .environmentObject(search)

                } label: {
                    VStack {
                        Text("Condition")
                    }
                }
            }
        }
        .navigationTitle("Filter")
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(.white)
        .edgesIgnoringSafeArea(.all)
    }
    

    
    private func binding(for key: String) -> Binding<[CheckModel]> {
        return Binding(get: {
            return search.modals[key] ?? []
        }, set: {
            search.modals[key] = $0
        })
    }
}



enum Direction {
    // enumeration definition goes here
    case ASC
    case DESC
}


struct SortView: View {
    @EnvironmentObject var search: SearchObject
    
    @State private var selection: CheckModel?

    
    var body: some View {
        
        VStack(alignment: .leading) {
                
                List(selection: $selection) {
                    
                    ForEach(search.modals["sort"] ?? [], id: \.id) { option in

                        HStack {
                            Image(systemName: option.isSelected ? "checkmark.circle" : "circle")
                                    .foregroundColor(.blue)
                            

                            VStack(alignment: .leading) {
                                Text("\(option.description)")
                            }
                   
                            Spacer()
                        }
                        .contentShape(Rectangle())
                        .frame(height: 50)
                        .onTapGesture {
                            self.search.resetKey(key: "sort")
                            self.selection = option
                            self.search.toggle(key: "sort", id: option.id)
                            self.search.updated.toggle()
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
    
    
    
    private func binding(for key: String) -> Binding<[CheckModel]> {
        return Binding(get: {
            return search.modals[key] ?? []
        }, set: {
            search.modals[key] = $0
        })
    }
}

struct ResultView: View {
    @EnvironmentObject var meta: Meta
    @EnvironmentObject var search: SearchObject

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
                                    //self.dataSource.fetch(path: "/auto/search/\(meta.query)", params: params)

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
        
        .onChange(of: search.updated) { _ in
            self.processQuery()
        }
        .onAppear {
           // self.processQuery()
          //self.dataSource.fetch(path: "/auto/search/\(meta.query)", params: params)
        }
        
    }
    
    func processSort() {
        let selectSort = search.modals["sort"]!.filter { cell in
            return cell.isSelected
        }
        
        if selectSort.isEmpty {
            
            return
        }
        
        var direction = Direction.ASC
        var order = "price"
        
        switch selectSort[0].id {
            case 0:
                order = "id"
                direction = Direction.ASC
            case 1:
                order = "price"
                direction = Direction.ASC
            case 2:
                order = "price"
               direction = Direction.DESC
            case 3:
                order = "year"
                direction = Direction.ASC
            case 4:
                order = "year"
                direction = Direction.DESC
            case 5:
                order = "mileage"
                direction = Direction.ASC
            case 6:
                order = "mileage"
                direction = Direction.DESC
            case 7:
                order = "created";
                direction = Direction.ASC;
            default:
                order = "id";
                direction = Direction.ASC;
        }
        
        search.components["sortBy"] = order
        search.components["sortDirection"] = direction == Direction.ASC ? "0" : "1"
        
    }
    
    func processFilter() -> Void {
        
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
        
        
        if !selectBodys.isEmpty {
            //params.append(URLQueryItem(name: "bodyCode", value: selectBodys))
            search.components["bodyCode"] = selectBodys
        }
        
        if !selectTransmission.isEmpty {
            //params.append(URLQueryItem(name: "transmissionCode", value: selectTransmission))
            search.components["transmissionCode"] = selectTransmission
        }
        
        if !selectDrivetrains.isEmpty {
            //params.append(URLQueryItem(name: "drivetrainCode", value: selectDrivetrains))
            search.components["drivetrainCode"] = selectDrivetrains
        }
                          
        if !selectFuels.isEmpty {
            //params.append(URLQueryItem(name: "fuelCode", value: selectFuels))
            search.components["fuelCode"] = selectFuels
        }
                       
        search.components["path"] = selectMakes
    }
    
    
    func processQuery() -> Void {
        
        self.processFilter()
        self.processSort()
        
        
        var params = [URLQueryItem]()

        if search.components.keys.contains( "bodyCode") {
            params.append(URLQueryItem(name: "bodyCode", value: search.components["bodyCode"]))
        }
        
        if search.components.keys.contains( "transmissionCode") {
            params.append(URLQueryItem(name: "transmissionCode", value: search.components["transmissionCode"]))
        }
        
        if search.components.keys.contains( "drivetrainCode") {
            params.append(URLQueryItem(name: "drivetrainCode", value: search.components["drivetrainCode"] ))
        }
                          
        if search.components.keys.contains( "fuelCode") {
            params.append(URLQueryItem(name: "fuelCode", value: search.components["fuelCode"]))
        }
        
        if search.components.keys.contains( "sortBy") {
            params.append(URLQueryItem(name: "sortBy", value: search.components["sortBy"]))
        }
        
        if search.components.keys.contains( "sortDirection") {
            params.append(URLQueryItem(name: "sortDirection", value: search.components["sortDirection"]))
        }
        
        var path = meta.query
        if search.components.keys.contains( "path") {
            path = search.components["path"]!
        }
             
        self.params = params
        self.dataSource.reset()
        self.dataSource.fetch(path: "/auto/search/\(path)", params: params)
        
    }
    
}


struct SearchItem: Hashable, Identifiable {
    var id: Self {self}
    var name: String
    var children: [CheckModel]? = []

}


struct SearchView: View {
    
    @StateObject var search = SearchObject()

    
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
    
    @State var sort = [
        CheckModel(id: 0, type: "sort", description: "Relevance", isSelected: true),
        CheckModel(id: 1, type: "sort", description: "Price Low to High", isSelected: false),
        CheckModel(id: 2, type: "sort", description: "Price High to Low", isSelected: false),
        CheckModel(id: 3, type: "sort", description: "Year Low to High", isSelected: false),
        CheckModel(id: 4, type: "sort", description: "Year High to Low", isSelected: false),
        CheckModel(id: 5, type: "sort", description: "Mileage Low to High", isSelected: false),
        CheckModel(id: 6, type: "sort", description: "Mileage High to Low", isSelected: false)
    ]
    
    
    
    @State var showFilter = false
    @State var showSort = false
    @State var title = "Search"
    
    
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
                
                SearchRow()
                
                GeometryReader { geometry in
                    
                    
                    ZStack(alignment: .leading) {
                        
                        ResultView()
                            .frame(width: geometry.size.width, height: geometry.size.height)
                            .offset(x: self.showFilter || self.showSort ? geometry.size.width/1.5 : 0)
                            .disabled(self.showFilter || self.showSort ? true : false)
                        
                        if self.showFilter {
                            
        
                            FilterView()
                                .frame(width: geometry.size.width)
                                .transition(.move(edge: .leading))
                        }
                        
                        if self.showSort {
                            
                            SortView()
                                .frame(width: geometry.size.width)
                                .transition(.move(edge: .trailing))
                        }


                    }
                    .gesture(drag)
                }
                
            }
            .environmentObject(search)
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
            if self.makeModel.isEmpty {
                self.buildFuel()
                self.buildBody()
                self.buildMakes()
                self.buildDrivetrain()
                self.buildTransmission()
                self.buildConditions()
                self.buildColors()
                self.buildSort()
            }

            print("ON APPEAR SORT VIEW")
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
    
    
    func buildSort() {
        
        search.modals["sort"] = self.sort
        
    }
    
}
