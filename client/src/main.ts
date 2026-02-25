import { enableProdMode, importProvidersFrom, APP_INITIALIZER } from '@angular/core';
import { bootstrapApplication } from '@angular/platform-browser';
import { provideHttpClient, withInterceptorsFromDi, HTTP_INTERCEPTORS } from '@angular/common/http';
import { provideRouter } from '@angular/router';
import { LocationStrategy, HashLocationStrategy } from '@angular/common';
import { provideAnimations } from '@angular/platform-browser/animations';
import { FormsModule, ReactiveFormsModule } from '@angular/forms';

// UI Modules
import { NgbModule } from '@ng-bootstrap/ng-bootstrap';
import { MatSnackBarModule } from '@angular/material/snack-bar';
import { MatBottomSheetModule } from '@angular/material/bottom-sheet';
import { AngularSplitModule } from 'angular-split';

// App specific imports (Adjusted paths for main.ts location)
import { AppComponent } from './app/app.component';
import { rootRouterConfig } from './app/app.routes';
import { AppConfig } from "./app/config/app.config";
import { MapService } from './app/services/map/map.service';
import { SearchService } from './app/services/search/search.service';
import { ConfigService } from './app/services/config/config.service';
import { PlantdataService } from './app/services/data/plantdata.service';
import { AuthInterceptor } from './app/services/auth/AuthInterceptor';
import { environment } from './environments/environment';

if (environment.production) {
  enableProdMode();
}

export function initConfig(config: AppConfig) {
  return () => config.load();
}

bootstrapApplication(AppComponent, {
  providers: [
    // Services
    MapService,
    SearchService,
    ConfigService,
    PlantdataService,
    AppConfig,

    // Routing
    provideRouter(rootRouterConfig),
    { provide: LocationStrategy, useClass: HashLocationStrategy },

    // HTTP & Interceptors
    provideHttpClient(withInterceptorsFromDi()),
    { provide: HTTP_INTERCEPTORS, useClass: AuthInterceptor, multi: true },

    // Initializers
    {
      provide: APP_INITIALIZER,
      useFactory: initConfig,
      deps: [AppConfig],
      multi: true
    },

    // Animations
    provideAnimations(),

    // Shared Modules
    importProvidersFrom(
        FormsModule,
        ReactiveFormsModule,
        NgbModule,
        MatSnackBarModule,
        MatBottomSheetModule,
        AngularSplitModule
    )
  ]
}).catch(err => console.error(err));
