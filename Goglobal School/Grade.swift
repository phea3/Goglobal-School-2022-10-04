//
//  Grade.swift
//  Goglobal School
//
//  Created by Leng Mouyngech on 25/8/22.
//
import SwiftUI

struct Grade: View {
    
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    @StateObject var enrollments: ListStudentViewModel = ListStudentViewModel()
    @State var ChoseTitle: String = ""
    @State var chose: Chose = .attendance
    @State var isShow: Bool = false
    @State private var selection: String? = nil
    @State var studentId: String = "6204ad568a628dd0c4e61e4d"
    @State var colorBlue: String = "LightBlue"
    @State var colorOrg: String = "LightOrange"
    @State var axcessPadding: CGFloat = 0
    let gradient = Color("BG")
    let Enrollment: [EnrollmentsViewModel]
    var parentId: String
    var barTitle: String
    var prop: Properties
    let Student: String
    var btnBack : some View { Button(action: {
        self.presentationMode.wrappedValue.dismiss()
    }) {
            backButtonView(prop: prop, barTitle: barTitle)
        }
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0){
                Divider()
                HStack{
                    Text("ថ្នាក់ រៀន \(Student)")
                        .font(.custom("Bayon", size: prop.isiPhoneS ? 12 : prop.isiPhoneM ? 14 : 16))
                    Rectangle()
                        .frame(maxHeight: 1)
                }
                .foregroundColor(Color("Blue"))
                .padding()
                .frame(width: .infinity, height: .infinity, alignment: .leading)
                VStack(spacing: 0){
                    List(Array(Enrollment.enumerated()), id: \.element.id){ index, item in
                        Choose(Grade: item.GradeId.GradeName , Class: item.ClassName, Programme: item.ProgramId.ProgramName, chose: $chose, isShow: $isShow, ChoseTitle: $ChoseTitle, selection: $selection, color: index % 2 == 0 ? colorOrg: colorBlue,prop:prop)
                            .foregroundColor( index % 2 == 0 ?  Color("bodyOrange") : Color("bodyBlue"))
                            .backgroundRemover()
                    }
                    .listStyle(GroupedListStyle())
                    NavigationLink(destination: Choosing(chose: chose, studentId: studentId, barTitle: ChoseTitle, prop: prop), tag: "attendance", selection: $selection) { EmptyView() }
                    NavigationLink(destination: Choosing(chose: chose, studentId: studentId, barTitle: ChoseTitle, prop: prop), tag: "absence", selection: $selection) { EmptyView() }
                    NavigationLink(destination: Choosing(chose: chose, studentId: studentId, barTitle: ChoseTitle, prop: prop), tag: "payment", selection: $selection) { EmptyView() }
                    NavigationLink(destination: Choosing(chose: chose, studentId: studentId, barTitle: ChoseTitle, prop: prop), tag: "score", selection: $selection) { EmptyView() }
                }
                .padding(.trailing)
                
            }
            .navigationBarTitleDisplayMode(.inline)
            .applyBG()
            .onAppear(perform: {
                enrollments.StundentAmount(parentId: parentId)
            })
        }
        .navigationBarItems(leading: btnBack)
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                HStack{
                    Image("user7")
                        .resizable()
                        .clipShape(Circle())
                        .aspectRatio(contentMode: .fill)
                        .frame(width: prop.isLandscape ? 30 : (prop.isiPhoneS ? 24 : prop.isiPhoneM ? 26 : 28), alignment: .center)
                }
            }
        }
    }
}

struct Choose: View {
    
    @State var showsheet: Bool = false
    @State var Grade: String
    @State var Class: String
    @State var Programme: String
    @Binding var chose: Chose
    @Binding var isShow: Bool
    @Binding var ChoseTitle: String
    @Binding var selection: String?
    var color: String
    var prop: Properties
    var body: some View {
        
        HStack(spacing: prop.isiPhoneS ? 16 : prop.isiPhoneM ? 18 : 20){
//            if !(prop.isiPad && (!prop.isLandscape)){
                Circle()
                    .frame(width: 49, height: 49, alignment: .center)
                    .overlay(
                        Image(systemName: "graduationcap.circle.fill")
                            .font(.system(size: 50))
                            .frame(width: 50, height: 50, alignment: .center)
                            .foregroundColor(.white)
                    )
//            }
            VStack(alignment: .leading){
                HStack(spacing: prop.isiPhoneS ? 3 : prop.isiPhoneM ? 4 : 5){
                    Text(Grade)
                        .listRowBackground(Color.yellow)
                        .font(.custom("Kantumruy", size: prop.isiPhoneS ? 10 : prop.isiPhoneM ? 12 : 14, relativeTo: .largeTitle))
                    
                    Text(Class)
                        .listRowBackground(Color.yellow)
                        .font(.custom("Kantumruy", size: prop.isiPhoneS ? 10 : prop.isiPhoneM ? 12 : 14, relativeTo: .largeTitle))
                }
                
                Text(Programme)
                    .listRowBackground(Color.yellow)
                    .font(.custom("Bayon", size: prop.isiPhoneS ? 10 : prop.isiPhoneM ? 12 : 14, relativeTo: .largeTitle))
            }
        }
        .padding()
        .hLeading()
        .background(Color(color))
        .cornerRadius(15)
        .onTapGesture {
            showsheet.toggle()
        }
        .halfSheet(showSheet: $showsheet) {
            // Half Sheet View...
            NavigationView{
                ZStack {
                    Color.white
                    VStack(alignment: .leading,spacing: prop.isiPhoneS ? 16 : prop.isiPhoneM ? 18 : 20){
                        Text("ជ្រើសរើស")
                            .font(.custom("Kantumruy", size: prop.isiPhoneS ? 16 : prop.isiPhoneM ? 18 : 20, relativeTo: .title2))
                            .foregroundColor(Color("Blue"))
                        TabButton(title: "កាលវិភាគសិក្សា", image: "calendar.badge.clock", chose: .attendance, selection: "attendance")
                        TabButton(title: "វត្តមានសិស្ស", image: "checklist", chose: .absence, selection: "absence")
//                        TabButton(title: "ប្រតិបត្តិពន្ទុ", image: "newspaper.fill", chose: .score, selection: "score")
//                        TabButton(title: "តម្លៃសិក្សា", image: "dollarsign.square.fill", chose: .payment, selection: "payment")
                        Spacer()
                    }
                    .padding(.horizontal)
                    .hLeading()
                }
            }
        } onEnd: {
            print("")
        }
    }
    @ViewBuilder
    func TabButton(title: String, image: String, chose: Chose, selection: String) -> some View{
        Button {
            self.chose = chose
            showsheet.toggle()
            self.isShow = true
            self.ChoseTitle = title
            self.selection = selection
            
        } label: {
            HStack(spacing: prop.isiPhoneS ? 6 : prop.isiPhoneM ? 8 : 10){
                Image(systemName: image)
                    .font(.title)
                Text(title)
                    .font(.custom("Bayon", size: 20, relativeTo: .title2))
            }
            .foregroundColor(Color("Blue"))
        }
    }
}

struct Grade_Previews: PreviewProvider {
    static var previews: some View {
        let EnrollmentVM = EnrollmentsViewModel(enrollment: GetStudentsByParentsQuery.Data.GetStudentsByParent.Enrollment(_id: ""))
        let prop = Properties(isLandscape: false, isiPad: false, isiPhone: false, isiPhoneS: false, isiPhoneM: false, isiPhoneL: false, isSplit: false, size: CGSize(width:  0, height:  0))
        Grade(Enrollment: [EnrollmentVM], parentId: "", barTitle: "",prop: prop, Student: "")
    }
}

struct ResultView: View {
    var choice: String
    
    var body: some View {
        Text("You chose \(choice)")
    }
}