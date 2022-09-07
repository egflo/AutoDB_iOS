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
        }
        
    }
}


struct CheckRow: View {
    
    @Binding var cells: [CheckModel]
    @Binding var updated: Bool
        
    var body: some View {
        
        VStack {
            
            List($cells) { $cell in
                
                CheckCellView(cell: $cell)
                    .onChange(of: cell) { _ in
                        updated.toggle()
                    }
                
 
     
            }
        }
    }
    
}






struct FilterView: View {
    
    @Binding var components: [String: String]
    
    @Binding var makes: [CheckModel]
    @Binding var bodyTypes: [CheckModel]
    @Binding var fuels: [CheckModel]
    @Binding var drivetrains: [CheckModel]
    @Binding var transmissions: [CheckModel]

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
        
        VStack(alignment: .leading) {
            
            Collapsible(
                label: {
                    Text("Location")
                    
                },
                content: {
                    HStack {
                        VStack {
                            
                            TextField("Postcode", text: $postcode)
                                .padding()
                                .keyboardType(.decimalPad)
                            
                            
                            Picker("Select a range", selection: $rangeSelect) {
                                ForEach(range, id: \.self) {
                                    Text($0.description)
                                }
                            }
                            .pickerStyle(.menu)
                            
                        }

                    }
                    .frame(maxWidth: .infinity)
                }
            )
            .frame(maxWidth: .infinity)
            .padding(.top, 100)

            
            Collapsible(
                label: {
                    Text("Mileage")
                    
                },
                content: {
                    HStack {
                        VStack {
                            Slider(
                                value: $mileage,
                                in: 0...400000,
                                onEditingChanged: { editing in
                                    isEditing = editing
                                }
                            )
                            Text("\(Int(mileage))")
                                .foregroundColor(isEditing ? .red : .blue)
                        }

                    }
                    .frame(maxWidth: .infinity)
                }
            )
            .frame(maxWidth: .infinity)
            
            
            Collapsible(
                label: {
                    Text("Makes")
                    
                },
                content: {
                    HStack {
                        CheckRow(cells: $makes, updated: $updated)

                    }
                    .frame(maxWidth: .infinity)
                }
            )
            .frame(maxWidth: .infinity)

            
            Collapsible(
                label: {
                    Text("Body")
                    
                },
                content: {
                    HStack {
                        CheckRow(cells: $bodyTypes, updated: $updated)

                    }
                    .frame(maxWidth: .infinity)
                }
            )
            .frame(maxWidth: .infinity)
            
            Collapsible(
                label: {
                    Text("Fuel")
                    
                },
                content: {
                    HStack {
                        CheckRow(cells: $fuels, updated: $updated)

                    }
                    .frame(maxWidth: .infinity)
                }
            )
            .frame(maxWidth: .infinity)
            
            
            Collapsible(
                label: {
                    Text("Drivetrain")
                    
                },
                content: {
                    HStack {
                        CheckRow(cells: $drivetrains, updated: $updated)

                    }
                    .frame(maxWidth: .infinity)
                }
            )
            .frame(maxWidth: .infinity)
            
            Collapsible(
                label: {
                    Text("Transmission")
                    
                },
                content: {
                    HStack {
                        CheckRow(cells: $transmissions, updated: $updated)

                    }
                    .frame(maxWidth: .infinity)
                }
            )
            .frame(maxWidth: .infinity)
            
            Spacer()
        }
        .onChange(of: updated){ _ in
            print("Updated Checklist")
            self.processQuery()
        }
        .border(.red)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(.white)
        .edgesIgnoringSafeArea(.all)
    }
    
    func processQuery() -> Void {
        
        let selectMakes = makes.filter { cell in
            return cell.isSelected
        }.map{$0.description}.joined(separator: "/")
        
        let selectBodys = bodyTypes.filter { cell in
            return cell.isSelected
        }.map{String($0.id)}.joined(separator: "_")
        
        let selectTransmission = transmissions.filter { cell in
            return cell.isSelected
        }.map{String($0.id)}.joined(separator: "_")
        
        let selectDrivetrains = drivetrains.filter { cell in
            return cell.isSelected
        }.map{String($0.id)}.joined(separator: "_")
        
        
        let selectFuels = fuels.filter { cell in
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
        

        print(selectBodys)
        
        
    }
}



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
        
        VStack(alignment: .leading, spacing: 20) {
                
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
       

            .padding(.top, 100)


            Spacer()
        }
        .padding()
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
    
    @Binding var components: [String:String]

    
    @Binding var make: [CheckModel]
    @Binding var bodyTypes: [CheckModel]
    @Binding var fuel: [CheckModel]
    @Binding var drivetrain: [CheckModel]
    @Binding var transmission: [CheckModel]
    
    
    @State var path = "BMW"
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
                                    self.dataSource.fetch(path: path, params: params)

                                }
                            }
                        })
                    }
                    
                }
                
                if dataSource.isLoadingPage {
                    ProgressView()
                }

            }
        }
        .onChange(of: components) { _ in
            self.processQuery()
        }
        .onAppear {
            self.processQuery()
            //self.dataSource.fetch(path: "auto/search/\(query)")
            
            self.dataSource.fetch(path: path, params: params)
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
        
        self.path = "bmw"
        if self.components.keys.contains( "path") {
            path = self.components["path"]!
        }
             
        self.params = params
        self.dataSource.reset()
        self.dataSource.fetch(path: path, params: params)


    }
    
}


struct SearchView: View {
    let width = UIScreen.main.bounds.width
    let height = UIScreen.main.bounds.height
    
    @State var urlComponents = URLComponents()
    
    
    @State var components = [String: String]()
    
    
    @State var makeModel = [CheckModel]()
    @State var bodyModel = [CheckModel]()
    @State var fuelModel = [CheckModel]()
    @State var colorModel = [CheckModel]()
    @State var driveModel = [CheckModel]()
    @State var transmissionModel = [CheckModel]()
    @State var conditionModel = [CheckModel]()

    
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
        
        NavigationView {
            
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    
                    ResultView(components: $components, make: $makeModel, bodyTypes: $bodyModel, fuel: $fuelModel,
                               drivetrain: $driveModel, transmission: $transmissionModel)
                        .frame(width: geometry.size.width, height: geometry.size.height)
                        .offset(x: self.showFilter || self.showSort ? geometry.size.width/1.5 : 0)
                        .disabled(self.showFilter || self.showSort ? true : false)
                    
                    if self.showFilter {
                        
    
                        FilterView(components: $components, makes: $makeModel, bodyTypes: $bodyModel, fuels: $fuelModel,
                                   drivetrains: $driveModel, transmissions: $transmissionModel)
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
            .navigationBarTitle("\(self.title)", displayMode: .inline)
            .navigationBarItems(leading: (
                
                HStack {
                    Button(action: {
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
                            withAnimation {
                                self.showSort.toggle()
                            }
                        }) {
                            Image(systemName: "arrow.up.arrow.down.circle")
                                .imageScale(.large)
                        }
                        
                    }


            )
        }
        
        .onAppear {
            self.buildFuel()
            self.buildBody()
            self.buildMakes()
            self.buildDrivetrain()
            self.buildTransmission()
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
                    for value in values {
                        let data = CheckModel(id: value.id,  type: "body", description: value.type, isSelected: false)
                        self.bodyModel.append(data)
                    }
                    
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
                    for value in values {
                        let data = CheckModel(id: value.id, type: "make", description: value.name, isSelected: false)
                        self.makeModel.append(data)
                    }
                    
                }
            case .failure(let error):
                DispatchQueue.main.async {
                    print("Error")
                    
                }
            }
        }
    }

    
}
