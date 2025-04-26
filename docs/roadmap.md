# Product Roadmap (Prioritized & Organized)

## ✅ Completed Tasks
- [✔] Sign-In Feedback Improvements (Clear rejection messages + guidance)
- [✔] Initial API Optimization (Reduced Supabase calls in admin dashboard)
- [✔] Modular Code Refactoring (Split Dart files + better folder structure)
- [✔] Admin Screen Modularization (Improved widgets + caching implementation)
- [✔] Custom Splash Screen Implementation
- [ ] can we try and debug the app on ios ?
## 🚀 P0 - Critical Path (Current Sprint)
1. **Performance Hotfixes**
   - [ ] Fix Gradle/Kotlin build errors (Clean project setup)
   - [ ] Diagnose thread overutilization (App launch/sign-up page)
   - [ ] Optimize Sign-Up Page Performance (Address lag/slowness)

2. **Core Authentication Flow**
   - [✔] Implement ID/Password Sign-In Option (Secondary method)
   - [✔] Add Back Button to Sign-Up Process
   - [ ] Investigate how the sign in works and what does it return and how to make the user change the password in the future
   - [ ] make sure the back button doesnt appear after the user adding 
   pictures so it doesnt add the pictures 2 times ()
   - [ ] make sure the back button doesnt return black screen
   - [✔] Country Selection Dropdown (Replace text input)
   - [ ] Universal Form Validations (11 numbers for egypt and other certain number of digits for other countries and fix the size of the deop down)
   - [✔] Re-order how the fields are displayed and prioritize and remove the not needed fields
   - [✔] add the user name and password obtion to the main auth screen
   - [ ] make sure the colors are changed of the messages for better handling , make sure u alert the user if the name has been taken by already existing user

3. **Database & Storage**
   - [✔] Configure Supabase Photo Storage (User uploads support)
   - [✔] optimize the supabase storage and how the compression of the image , maxing 50 kb or somethin like that 
   - [✔] Production Ready Storage Policies
   - [ ] revise the Production Ready Storage Policies
   - [ ] revise already working sql codes and eliminate the not runnning ones
   - [ ] create the name of the folder created in the bucket for the user , with their name_id_auth , while name is the user namd and the id is their id and the auth is fixed letter like literarlly auth
   - [✔] make sure only one user has 3 images , why in the bucket there is more

## 📈 P1 - High Priority Features
1. **Sign-Up Process Overhaul**
   - [✔] Re-order Form Fields by Priority
   - [✔] Mediator Document Upload (Live photo + ID front/back)(find the best way to do this and minimize the cost and space in supabase database)
   - [ ] fix the splash screen not loading first and add a good loading screens , fix the size of the app icon 
   - [✔] Handle Sign-Up Interruptions (Partial progress recovery)
   - [ ] add loading animations and progress bar screen solely for uploading the photos for the mediator and the merchant
   - [ ] edit the admin dashboard screen with the new data and fields after fixing the supabase

2. **Admin Dashboard 2.0**
   - [ ] Expandable User Cards (With pagination) (this may reduce the cost of the database , find a way to do so)
   - [ ] User ID number Displayed in Cards after expand
   - [ ] Quick Stats Overview (Replace empty top space and add the stats , and replace them with small quick stats)
   - [ ] Dedicated Stats Page (Bottom nav integration)
   - [ ] Real-Time Transaction Tracking (find the best way to do this and minimize the cost and space in supabase database)
   - [ ] create supabase screen tab in which to view the number of api calls and the database storage amount and other supabase related numbers for the supabase dashboard

3. **Performance & Cost**
   - [ ] first understand how to monitor the performance of the app and how to reduce the api calls and cost and how the caching will work and other techniques.
   - [ ] Advanced Caching Layer Implementation
   - [ ] API Call Audit & Cost Optimization

## 🎨 P2 - UX Improvements
1. **UI/Polish**
   - [ ] Color Scheme Enhancement (Richer palette + global styles)
   - [ ] Responsive Design Audit for diffrant devices (fields , screen size , image placholders and so on)(Cross-device testing)

2. **Admin Experience**
   - [✔] Add "Accepted Time" to History Cards
   - [ ] (not necesary)Bulk Action Controls (User banning/post deletion)

## 🔄 P3 - Technical Debt & Monitoring
- [ ] Performance Monitoring System (Processor load logging)
- [ ] Pending State Optimization (Consistent loading patterns)
- [ ] Regular API Usage Reviews (Monthly cost audits) 

# Progress Visualization
**Current Sprint Completion**: ▰▰▰▱▱▱▱▱▱▱ 30%  
**Overall Project Progress**: ▰▱▱▱▱▱▱▱▱▱ 10%

# Priority Legend
- ✅ Completed  
-  P0: Blocking issues & core functionality  
-  P1: High-value features  
-  P2: User-facing polish  
-  P3: Maintenance & monitoring

# Key Rationale
1. **Technical Foundation First**: Fixed build errors and performance issues before adding features
2. **User Flow Priority**: Authentication improvements before dashboard enhancements
3. **Cost Control**: Storage configuration before implementing upload features
4. **Progressive Disclosure**: Expandable cards before pagination implementation
5. **Validation First**: Form validations before complex document uploads
