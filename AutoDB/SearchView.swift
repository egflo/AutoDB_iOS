//
//  SearchView.swift
//  AutoDB
//
//

import Foundation
import SwiftUI
import ImageIO
import SDWebImageSwiftUI



struct CheckModel: Codable, Identifiable {
    var id: Int
    var description: String
    var isSelected: Bool
}

struct CheckCellView: View {
    @Binding var cell: CheckModel
    
    var body: some View {
        
        HStack {
            Image(systemName: cell.isSelected ? "checkmark.square" : "square")
                .onTapGesture {
                    cell.isSelected.toggle()
                }
            
            Text(cell.description)
        }
        
    }
}


struct CheckRow: View {
    
    @Binding var cells: [CheckModel]
    
    var body: some View {
        
        VStack {
            
            List($cells) { $cell in
                
                CheckCellView(cell: $cell)
                
            }
        }

    }
}






struct FilterView: View {
    
    @Binding var make: [CheckModel]
    @Binding var bodyTypes: [CheckModel]
    @Binding var fuel: [CheckModel]
    @Binding var drivetrain: [CheckModel]
    @Binding var transmission: [CheckModel]

    
    var body: some View {
        
        VStack(alignment: .leading) {
            
            Collapsible(
                label: {
                    Text("Makes")
                    
                },
                content: {
                    HStack {
                        CheckRow(cells: $make)
                    }
                    .frame(maxWidth: .infinity)
                }
            )
            .frame(maxWidth: .infinity)
            .padding(.top, 100)

            
            Collapsible(
                label: {
                    Text("Body")
                    
                },
                content: {
                    HStack {
                        CheckRow(cells: $bodyTypes)
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
                        CheckRow(cells: $fuel)
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
                        CheckRow(cells: $drivetrain)
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
                        CheckRow(cells: $transmission)
                    }
                    .frame(maxWidth: .infinity)
                }
            )
            .frame(maxWidth: .infinity)
            
            Spacer()
        }
        .border(.red)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(.white)
        .edgesIgnoringSafeArea(.all)
    }
}

struct SortView: View {
    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Image(systemName: "person")
                    .foregroundColor(.gray)
                    .imageScale(.large)
                Text("Profile")
                    .foregroundColor(.gray)
                    .font(.headline)
            }
            .padding(.top, 100)
            HStack {
                Image(systemName: "envelope")
                    .foregroundColor(.gray)
                    .imageScale(.large)
                Text("Messages")
                    .foregroundColor(.gray)
                    .font(.headline)
            }
                .padding(.top, 30)
            HStack {
                Image(systemName: "gear")
                    .foregroundColor(.gray)
                    .imageScale(.large)
                Text("Settings")
                    .foregroundColor(.gray)
                    .font(.headline)
            }
            .padding(.top, 30)
            Spacer()
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(.red)
        .edgesIgnoringSafeArea(.all)
    }
}

struct ResultView: View {
    
    @Binding var make: [CheckModel]
    @Binding var bodyTypes: [CheckModel]
    @Binding var fuel: [CheckModel]
    @Binding var drivetrain: [CheckModel]
    @Binding var transmission: [CheckModel]
    
    
    let query = "BMW"
    
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
                                    self.dataSource.fetch(path: "auto/search/\(query)")
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
        .onAppear {
            self.dataSource.fetch(path: "auto/search/\(query)")
        }
        
    }
    
    
    func buildQuery() -> Void {
        
        let filter_make = self.make.filter { make in
            
            return make.isSelected
        }
        
        for make in filter_make {
            print(make)
        }
        
    }
}


struct SearchView: View {
    let width = UIScreen.main.bounds.width
    let height = UIScreen.main.bounds.height
    
    
    @State var makeModel = [CheckModel]()
    @State var bodyModel = [CheckModel]()
    @State var fuelModel = [CheckModel]()
    @State var colorModel = [CheckModel]()
    @State var driveModel = [CheckModel]()
    @State var transmissionModel = [CheckModel]()
    @State var conditionModel = [CheckModel]()

    
    @State var showFilter = false
    @State var showSort = false

    
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
                    
                    ResultView(make: $makeModel, bodyTypes: $bodyModel, fuel: $fuelModel,
                               drivetrain: $driveModel, transmission: $transmissionModel)
                        .frame(width: geometry.size.width, height: geometry.size.height)
                        .offset(x: self.showFilter ? geometry.size.width/1.5 : 0)
                        .disabled(self.showFilter ? true : false)
                    
                    if self.showFilter {
                        
    
                        FilterView(make: $makeModel, bodyTypes: $bodyModel, fuel: $fuelModel,
                                   drivetrain: $driveModel, transmission: $transmissionModel)
                            .frame(width: geometry.size.width/1.5)
                            .transition(.move(edge: .leading))
                    }
                    
                    if self.showSort {
                        
        
                        
                        SortView()
                            .frame(width: geometry.size.width/1.5)
                            .transition(.move(edge: .trailing))
                    }


                }
                .gesture(drag)
            }
            .navigationBarTitle("Search", displayMode: .inline)
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
                        let data = CheckModel(id: value.id, description: value.description, isSelected: false)
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
    
    
    
    func buildDrivetrain() {
        let URL = "http://10.81.1.123:8080/auto/drivetrain/all"
        NetworkManager.shared.getRequest(of: [Drivetrain].self, url: URL) { (result) in
            switch result {
            case .success(let values):
                DispatchQueue.main.async {
                    for value in values {
                        let data = CheckModel(id: value.id, description: value.name, isSelected: false)
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
                        let data = CheckModel(id: value.id, description: value.type, isSelected: false)
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
                        let data = CheckModel(id: value.id, description: value.type, isSelected: false)
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
                        let data = CheckModel(id: value.id, description: value.name, isSelected: false)
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
