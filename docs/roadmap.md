# Product Roadmap (Prioritized & Organized)

## ✅ Completed Tasks
- [✔] Sign-In Feedback Improvements (Clear rejection messages + guidance)
- [✔] Initial API Optimization (Reduced Supabase calls in admin dashboard)
- [✔] Modular Code Refactoring (Split Dart files + better folder structure)
- [✔] Admin Screen Modularization (Improved widgets + caching implementation)
- [✔] Custom Splash Screen Implementation

## 🚀 P0 - Critical Path (Current Sprint)
1. **Performance Hotfixes**
   - [ ] Fix Gradle/Kotlin build errors (Clean project setup)
   - [ ] Diagnose thread overutilization (App launch/sign-up page)
   - [ ] Optimize Sign-Up Page Performance (Address lag/slowness)

2. **Core Authentication Flow**
   - [ ] Implement ID/Password Sign-In Option (Secondary method)
   - [ ] Add Back Button to Sign-Up Process
   - [ ] Country Selection Dropdown (Replace text input)
   - [ ] Universal Form Validations
   - [ ] Re-order how the fields are displayed and prioritize and remove the not needed fields
   - [ ] add the user name and password obtion to the main auth screen

3. **Database & Storage**
   - [ ] Configure Supabase Photo Storage (User uploads support)
   - [ ] Production Ready Storage Policies
   - [ ] create the name of the folder created in teh bucket for the user , with their name_id_auth , while name is the user namd and the id is their id and the auth is fixed letter like literarlly auth
   - [ ]

## 📈 P1 - High Priority Features
1. **Sign-Up Process Overhaul**
   - [ ] Re-order Form Fields by Priority
   - [ ] Mediator Document Upload (Live photo + ID front/back)(find the best way to do this and minimize the cost and space in supabase database)
   - [ ] Handle Sign-Up Interruptions (Partial progress recovery)
   - [ ] edit the admin dashboard screen with the new data and fields after fixing the supabase
   - [ ] add the user name and password obtion to the main auth screen

2. **Admin Dashboard 2.0**
   - [ ] Expandable User Cards (With pagination) (this may reduce the cost of the database , find a way to do so)
   - [ ] User ID Display in Cards after expand
   - [ ] Quick Stats Overview (Replace empty top space and add the stats , and replace them with small quick stats)
   - [ ] Dedicated Stats Page (Bottom nav integration)
   - [ ] Real-Time Transaction Tracking (find the best way to do this and minimize the cost and space in supabase database)

3. **Performance & Cost**
   - [ ] first understand how to monitor the performance of the app and how to reduce the api calls and cost and how the caching will work and other techniques.
   - [ ] Advanced Caching Layer Implementation
   - [ ] API Call Audit & Cost Optimization

## 🎨 P2 - UX Improvements
1. **UI/Polish**
   - [ ] Color Scheme Enhancement (Richer palette + global styles)
   - [ ] Responsive Design Audit (Cross-device testing)

2. **Admin Experience**
   - [ ] Add "Accepted Time" to History Cards
   - [ ] Bulk Action Controls (User banning/post deletion)

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
