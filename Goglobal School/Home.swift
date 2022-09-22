//
//  Home.swift
//  Goglobal School
//
//  Created by Leng Mouyngech on 25/8/22.
//

import SwiftUI
import Alamofire
import SDWebImageSwiftUI
import SwiftUITooltip
import ImageViewer

struct Home: View {
    
    @Environment(\.openURL) var openURL
    @ObservedObject var loginVM: LoginViewModel = LoginViewModel()
    @StateObject var academiclist: ListViewModel =  ListViewModel()
    @StateObject var monitor = Monitor()
    init(){
        UITabBar.appearance().isHidden = true
        self.tooltipConfig.enableAnimation = true
        self.tooltipConfig.animationOffset = 10
        self.tooltipConfig.animationTime = 1
        self.tooltipConfig.borderColor = .blue
    }
    @State var currentTab: Tab = .dashboard
    @State var animationFinished: Bool = false
    @State var animationStarted: Bool = false
    @State var gmail: String = (UserDefaults.standard.string(forKey: "Gmail") ?? "")
    @State var password: String = (UserDefaults.standard.string(forKey: "Password") ?? "")
    @State var forget: Bool = false
    @State var isempty: Bool = false
    @State var isLoading: Bool = false
    @State var showContact: Bool = false
    @State var hideTab: Bool = false
    @State var checkState: Bool = false
    @State var loggedIn: Bool = false
    @State var tooltipVisible = true
    @State private var showingAlert: Bool = false
    @State private var showingPassword: Bool = false
    @State private var noConnention: Bool = false
    @State private var showingImage: Bool = false
    @State private var showingAlertUpdate = true
    @State var image = Image("GoGlobalSchool")
    var tooltipConfig = DefaultTooltipConfig()
    
    var body: some View {
        ResponsiveView{ prop in
            ZStack{
                ImageBackgroundSignIn()
                if loginVM.isAuthenticated{
                    ZStack{
                        if !loggedIn{
                            EmptyView()
                                .setBG()
                        }else{
                            MainView(prop: prop)
                        }
                    }
                    .onAppear{
                        loginVM.login(email: gmail, password: password, checkState: checkState)
                        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                            loggedIn = true
                        }
                    }
                }
                else if (!gmail.isEmpty && !gmail.isEmpty) && loginVM.isAuthenticated {
                    EmptyView()
                        .onAppear{
                            loginVM.login(email: gmail, password: password, checkState: checkState)
                        }
                }else if !loginVM.isAuthenticated{
                    LoginView(prop: prop)
                }else{
                    progressingView(prop: prop)
                }
                FlashScreen(prop:prop)
            }
            .alert("គ្មានអ៉ីនធើណេត", isPresented: $noConnention) {
                        Button("OK", role: .cancel) { }
                }
            .onAppear{
                VersionCheck.shared.checkAppStore() { isNew, version, linker in
                    print("IS NEW VERSION AVAILABLE: \(String(describing: isNew)), APP STORE VERSION: \(String(describing: version)), APP TRACK VIEW URL: \(String(describing: linker))")
                    }
                if !loginVM.isAuthenticated{
                    DispatchQueue.main.async {
                        self.isLoading = false
                    }
                }
            
                if monitor.status.rawValue == "connected" {
                    DispatchQueue.main.async {
                        self.noConnention = false
                    }
                } else{
                    DispatchQueue.main.async {
                        self.noConnention = true
                    }
                }
            }
            .ignoresSafeArea()
        }
        .ignoresSafeArea(.container, edges: .leading)
    }
    
    @ViewBuilder
    func MainView(prop: Properties)-> some View{
        ZStack{
            TabView(selection: $currentTab){
                // MARK: Need to Apply BG For Each Tab View
                Dashboard(userProfileImg: loginVM.userProfileImg, isLoading: $isLoading, parentId: loginVM.userId, activeYear: academiclist.academicYearId, prop: prop)
                    .tag(Tab.dashboard)
                Education(userProfileImg: loginVM.userProfileImg, isLoading: $isLoading, parentId: loginVM.userId, academicYearName: academiclist.khmerYear, prop: prop)
                    .tag(Tab.education)
                Calendar(userProfileImg: loginVM.userProfileImg, isLoading: $isLoading, prop: prop, activeYear: academiclist.academicYearId)
                    .tag(Tab.bag)
                Profile(logout: loginVM, uploadImg: UpdateMobileUserProfileImg(), Loading: $isLoading, hideTab: $hideTab, checkState: $checkState, prop: prop)
                    .tag(Tab.book)
            }
            .alert("សូមធ្វើការដំឡើង Version \(VersionCheck.shared.appStoreVersion ?? "") នៅក្នុង App Store!", isPresented: .constant(VersionCheck.shared.newVersionAvailable ?? false)) {
                        Button("យល់ព្រម") {openURL(URL(string: VersionCheck.shared.appLinkToAppStore ?? "")!) }
                        Button("មិនយល់ព្រម", role: .cancel)  { }
                    }
            .alert("គ្មានអ៉ីនធើណេត", isPresented: $noConnention) {
                        Button("OK", role: .cancel) { }
                }
            // MARK: Custom to Bar
            CustomTabBar(currentTab: $currentTab,prop: prop)
                .background(RoundedCorners(color: .white, tl: 30, tr: 30, bl: 0, br: 0))
                .frame(maxWidth: prop.isLandscape || prop.isSplit ? 400 : prop.isiPad ? 400 : .infinity, maxHeight: .infinity, alignment: .bottom)
                .opacity( hideTab ? 0 : animationStarted ? 1:0)
                .onAppear{
                    academiclist.activeAcademicYear()
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                        withAnimation(.easeInOut(duration: 0.7)){
                            animationStarted = true
                        }
                    }
                }
        }
    }
    
    func FlashScreen(prop: Properties)-> some View {
        ZStack{
            Color.white
                .ignoresSafeArea()
            ImageBackgroundSignIn()
            VStack{
                Spacer()
                LogoGoglobal(prop:prop)
                Spacer()
                footer(prop: prop)
            }
            .padding(prop.isiPhoneS ? 25: prop.isiPhoneM ? 30 : prop.isiPhoneL ? 35 : 40)
        }
        .opacity(animationFinished ? 0:1)
        .onAppear{
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                withAnimation(.easeInOut(duration: 0.7)){
                    animationFinished = true
                }
            }
        }
    }
    
    func LoginView(prop: Properties)-> some View{
        ZStack{
            VStack{
                Spacer()
                Button {
//                    self.showingImage = !self.showingImage
                } label: {
                    LogoGoglobal(prop:prop)
                }
                .opacity(prop.isLandscape && prop.isiPhone ? 0:1)
                VStack{
                    Text("ចូលប្រើកម្មវិធី")
                        .font(.custom("Bayon", size: prop.isiPhoneS ? 21 : prop.isiPhoneM ? 23 : prop.isiPhoneL ? 25 : 27, relativeTo: .largeTitle))
                        .foregroundColor(Color("ColorTitle"))
                }
                .opacity(prop.isLandscape && prop.isiPhone ? 0:1)
                Spacer()
                VStack(spacing: prop.isiPhoneS ? 14 : prop.isiPhoneM ? 16 : prop.isiPhoneL ? 18 : 20){
                    VStack(alignment: .leading, spacing: prop.isiPhoneS ? 4 : prop.isiPhoneM ? 6 : prop.isiPhoneL ? 8 : 10) {
                        Text("អ៉ីម៉ែល")
                            .font(.custom("Kantumruy", size: prop.isiPhoneS ? 15 : prop.isiPhoneM ? 17 : prop.isiPhoneL ? 19 : 21, relativeTo: .body))
                            .foregroundColor(.blue)
                        let binding = Binding<String>(get: {
                            self.gmail
                        }, set: {
                            self.gmail = $0.lowercased()
                        })
                        TextField("បញ្ជូលអ៉ីម៉ែល", text: binding)
                            .keyboardType(.emailAddress)
                            .padding(prop.isiPhoneS ? 12 : prop.isiPhoneM ? 14 : prop.isiPhoneL ? 16 : 18)
                            .cornerRadius(10)
                            .overlay(
                                RoundedRectangle(cornerRadius: 10)
                                    .stroke(isempty ? .red:.blue.opacity(0.5), lineWidth: 1)
                            )
                    }
                    
                    VStack(alignment: .leading, spacing: prop.isiPhoneS ? 4 : prop.isiPhoneM ? 6 : prop.isiPhoneL ? 8 : 10) {
                        Text("ពាក្យសម្ងាត់")
                            .font(.custom("Kantumruy", size: prop.isiPhoneS ? 15 : prop.isiPhoneM ? 17 : prop.isiPhoneL ? 19 : 21, relativeTo: .body))
                            .foregroundColor(.blue)
                        SecureTextFieldToggle(text: $password, isempty: isempty, prop: prop)
                    }
                    VStack{
                        Button {
                            loginVM.login(email: gmail, password: password, checkState: checkState)
                            self.isLoading = true
                            if self.gmail.isEmpty || password.isEmpty {
                                self.isempty = true
                                self.isLoading = false
                            }else{
                                DispatchQueue.main.asyncAfter(deadline: .now() + 3){
                                    if !loginVM.isAuthenticated{
                                        self.isLoading = false
                                        self.forget = true
                                        showingAlert = true
                                    }else{
                                        DispatchQueue.main.async{
                                            self.isLoading = false
                                        }
                                    }
                                }
                            }
                            if checkState{
                                UserDefaults.standard.set(self.gmail, forKey: "Gmail")
                                UserDefaults.standard.set(self.password, forKey: "Password")
                            }
                            
                        } label: {
                            Text("ចូលកម្មវិធី")
                                .font(.custom("Bayon", size: prop.isiPhoneS ? 16 : prop.isiPhoneM ? 18 : prop.isiPhoneL ? 22 : 24, relativeTo: .largeTitle))
                                .foregroundColor(.white)
                                .padding(prop.isiPhoneS ? 6 : prop.isiPhoneM ? 7 : prop.isiPhoneL ? 8 : 10)
                                .frame(maxWidth: .infinity)
                                .background(.blue)
                                .cornerRadius(10)
                        }
                        .alert("គណនីរបស់លោកអ្នកមិនត្រឹមត្រូវទេ", isPresented: $showingAlert) {
                                    Button("OK", role: .cancel) { }
                                }
                        HStack(spacing: 0){
                            Button(action:
                                    {
                                self.checkState.toggle()
                            }) {
                                HStack(alignment: .center, spacing: 10) {
                                    //2. Will update according to state
                                    Image(systemName: self.checkState ?"checkmark.square": "square")
                                        .font(.system(size: 20))
                                        .padding(.bottom, 5)
                                    Text("ចងចាំពាក្យសម្ងាត់?")
                                        .font(.custom("Kantumruy", size: prop.isiPhoneS ? 11 : prop.isiPhoneM ? 13 : prop.isiPhoneL ? 15 : 17, relativeTo: .body))
                                        .foregroundColor(.blue)
                                }
                            }
                            
                            Spacer()
                            
                            Button {
                                self.showContact = true
                            } label: {
                                Text("ភ្លេចពាក្យសម្ងាត់?")
                                    .font(.custom("Kantumruy", size: prop.isiPhoneS ? 11 : prop.isiPhoneM ? 13 : prop.isiPhoneL ? 15 : 17, relativeTo: .body))
                                    .foregroundColor(forget ? .red : .blue)
                            }
                            .sheet(isPresented: $showContact) {
                                SheetContact(prop: prop)
                            }
                            
                        }
                        .padding(.horizontal,2)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    .padding(.top,5)
                }
                .frame(maxWidth: prop.isiPad ? 400 : prop.isiPhoneL ? 400 : .infinity )
                Spacer()
                footer(prop: prop)
                    .opacity(prop.isLandscape && prop.isiPhone ? 0:1)
            }
            .padding(prop.isiPhoneS ? 25: prop.isiPhoneM ? 30 : prop.isiPhoneL ? 35 : 40)
            if isLoading{
                progressingView(prop: prop)
            }
            if showingImage{
                VStack{
                    Spacer()
                    ProgressView()
                    Spacer()
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .overlay(ImageViewer(image: self.$image, viewerShown: self.$showingImage, closeButtonTopRight: true))
            }
        }
    }
    
    func footer(prop:Properties)-> some View{
        VStack(spacing:  prop.isiPhoneS ? 1 : prop.isiPhoneM ? 2 : prop.isiPhoneL ? 3 : 10){
            Text("Power by:")
                .font(.system( size: prop.isiPhoneS ? 14 : prop.isiPhoneM ? 16 : prop.isiPhoneL ? 18 : 20))
                .foregroundColor(Color("footerColor"))
            Text("Go Global Tech")
                .font(.system(size: prop.isiPhoneS ? 16 : prop.isiPhoneM ? 18 : prop.isiPhoneL ? 20 : 22).bold())
                .foregroundColor(Color("footerColor"))
            FooterImg(prop: prop)
                .padding(.top, 8)
        }
    }
}

struct SecureTextFieldToggle: View{
    @State var isSecureField: Bool = true
    @Binding var text: String
    var isempty: Bool
    var prop: Properties
    var body: some View{
        
        HStack{
            HStack{
                if isSecureField{
                    SecureField("បញ្ជូលពាក្យសម្ងាត់", text: $text)
                }else{
                    let binding = Binding<String>(get: {
                        self.text
                    }, set: {
                        self.text = $0.lowercased()
                    })
                    TextField("បញ្ជូលពាក្យសម្ងាត់", text: binding)
                }
            }
            Spacer()
            Button {
                self.isSecureField.toggle()
            } label: {
                Image(systemName: self.isSecureField ? "eye.fill" : "eye.slash.fill")
                    .foregroundColor(.blue)
            }
        }
        .textContentType(.password)
        .padding(prop.isiPhoneS ? 12 : prop.isiPhoneM ? 14 : prop.isiPhoneL ? 16 : 18)
        .cornerRadius(10)
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .stroke(isempty ? .red : .blue .opacity(0.5), lineWidth: 1)
        )
    }
}
struct Home_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
