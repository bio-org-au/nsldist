import {AngularSplitModule} from "angular-split";

import {ChangeDetectorRef, Component, Input, OnInit, Output} from '@angular/core';
import {ActivatedRoute, Route, Router} from '@angular/router';
import {MapService} from '../services/map/map.service';
import {ConfigService} from '../services/config/config.service';
import {PlantdataService} from '../services/data/plantdata.service';
import * as L from 'leaflet';
import {SearchService} from '../services/search/search.service';
import {HttpErrorResponse} from '@angular/common/http';
import {catchError} from 'rxjs/operators';
import {Observable, throwError} from 'rxjs';
import {ComponentService} from '../services/component/component.service';
import {TriggerService} from '../services/trigger/trigger.service';
import {AppConfig} from '../config/app.config';
import {LeafletMouseEvent} from 'leaflet';
import {MatSnackBar} from '@angular/material/snack-bar';
import {MatBottomSheet} from '@angular/material/bottom-sheet';
import {LivingService} from '../services/living/living.service';
import {FormsModule} from "@angular/forms";
import {CommonModule} from "@angular/common";
import {NavigatorComponent} from "../components/navigator/navigator.component";
import {InfoComponent} from "../components/info/info.component";
import {StatusComponent} from "../components/status/status.component";

@Component({
    selector: 'app-index',
    standalone: true,
    imports: [FormsModule, CommonModule, NavigatorComponent, InfoComponent, StatusComponent, AngularSplitModule],
    templateUrl: './index.component.html',
    styleUrls: ['./index.component.css']
})
export class IndexComponent implements OnInit {
    // @Input() jsonData: any;
    @Input() advanced = false;
    @Input() version = 0; // dummy used to trigger change detection
    location: string = '';
    selectedSection: string = '';
    context: string;
    username: string = '';
    password: string = '';
    message: string = '';
    stocktake: boolean = false;
    treeAssessment: boolean = false;
    ntnl: boolean =false;
    assessment: boolean = false;
    recentlyMapped: boolean = false;
    recentlyMappedDate!: Date
    startupComplete!: Promise<any>;
    showInfo: boolean = false;
    legendSee = true
    waterIcon = L.divIcon({ html: '<i class="mapIconCls">&#xE019;</i>', iconSize: [20, 20], iconAnchor: [10, 10], className: 'mapIcon' })

    direction = 'vertical'
    sizes = {
        percent: {
            area1: 20,
            area2: 60,
            area3: 20,
        },
        pixel: {
            area1: 120,
            area2: 300,
            area3: 160,
        },
    }

    constructor(private router: Router,
                private mapService: MapService,
                private plantdataService: PlantdataService,
                public configService: ConfigService,
                private triggerService: TriggerService,
                private snackBar: MatSnackBar,
                private bottomSheet: MatBottomSheet,
                private search: SearchService,
                private livingService: LivingService,
                private route: ActivatedRoute,
                private componentService: ComponentService,
                private cdRef: ChangeDetectorRef,
                public config: AppConfig) {
        this.context = ConfigService.context();
//        this.showInfo = this.config.getConfig('showInfo');
    }

    get jsonData(): any {
        return this.plantdataService.jsonData;
    }

    set jsonData(value: any) {
        this.plantdataService.jsonData = value;
    }

    dragEnd(unit: 'percent' | 'pixel', {sizes}: {sizes : number[]}) {
        if (unit === 'percent') {
            this.sizes.percent.area1 = sizes[0];
            this.sizes.percent.area2 = sizes[1];
        } else if (unit === 'pixel') {
            this.sizes.pixel.area1 = sizes[0];
            this.sizes.pixel.area2 = sizes[1];
            this.sizes.pixel.area3 = sizes[2];
        }
        window.dispatchEvent(new Event('resize'));
    }

    ngOnInit(): void {
        const that: IndexComponent = this;

        // this.triggerService.remodel.subscribe( (jsonData: any) => {
        //     console.log('remodel');
        //     that.version = that.version + 1;
        //     that.plantdataService.jsonData = jsonData;
        //     this.jsonData = jsonData;
        // });
        // this.triggerService.zoom.subscribe( (n) => {
        //     that.plantdataService.zoom();
        // });
        // this.plantdataService.sectionClick.subscribe((section) => {
        //    that.sectionClick(section);
        // });
        this.mapService.makeMap();
        setTimeout(() => {
            this.showInfo = this.config.getConfig('showInfo') || false;
            this.showInfo = (this.showInfo === true);
            window.dispatchEvent(new Event('resize'));
//            this.cdRef.detectChanges(); // Tell Angular to check one last time
        }, 0);
        this.mapService.map.addEventListener('mousemove', (event: LeafletMouseEvent) => {
            const lat = Math.round(event.latlng.lat * 100000) / 100000;
            const lng = Math.round(event.latlng.lng * 100000) / 100000;
            that.location = 'Coordinates: ' + lat.toFixed(5) + ' ' + lng.toFixed(5) + ' ';
            // this.cdRef.detectChanges();
        });
    }

    login() {
        const that: IndexComponent = this;
        const obs = this.configService.login(this.username, this.password);
        obs.subscribe(js => {
            if (js['success']) {
                that.configService.user = js['user'];
                that.configService.user.canStocktake = that.configService.user?.roles?.indexOf('ROLE_LC_GARDEN_PROCESS_ITEM') > -1;
                that.legendSee = false;
                this.mapService.zoomEndHandler();
            }
            that.password = null;
            that.message = js['message'];
            }
        );
        obs.pipe(
                catchError((error: HttpErrorResponse) => {
                    this.message = '';
                    if (error.error instanceof ErrorEvent) {
                        // client-side error
                        this.message = `Error: ${error.error.message}`;
                    } else {
                        // server-side error
                        this.message = `HTTP status code: ${error.status}\nMessage: ${error.message}`;
                    }
                    console.log('catchError login: ' + this.message);
                    return throwError(error.error);
                })
            )
    }

    logout() {
        const that: IndexComponent = this;
        console.log('logout ' + this.username + ' ' + this.password);
        this.configService.logout().subscribe(jsonData => {
            // TODO check if this works when the server is down.
            that.configService.user = undefined;
            that.username = '';
            that.password = '';
            that.legendSee = true;
            this.message = jsonData['message'];
            this.mapService.zoomEndHandler();
            this.jsonData.criteria.ntnl = false
            this.triggerService.redraw.emit(false);
            console.log('logoutdone: ' + jsonData['username'] + ' ' + jsonData['password']);
        });
    }

    sectionClick(section: string) {
        this.selectedSection = section;
        console.log('set selectedSection: ' + section);
    }

    hasRoute(controllerName: string): boolean {
        return this.router.config.some((route: Route) => {
            if (route.path === controllerName) {
                return true;
            }
            return false;
        });
    }

    showStocktake() {
        if (this.plantdataService.jsonData.criteria) {
            this.getSearchCriteria(this.plantdataService.jsonData.criteria);
            this.triggerService.redraw.emit(false);
        }
    }

    showTreeAssessment() {
        if (this.plantdataService.jsonData.criteria) {
            this.getSearchCriteria(this.plantdataService.jsonData.criteria);
            this.triggerService.redraw.emit(false);
        }
    }

    legendHide() {
        this.legendSee = !this.legendSee
    }


    showAssessment() {
        if (this.plantdataService.jsonData.criteria) {
            this.getSearchCriteria(this.plantdataService.jsonData.criteria);
            this.triggerService.redraw.emit(false);
        }
    }

    getSearchCriteria(criteria) {
        criteria['stocktake'] = this.stocktake;
        criteria['treeAssessment'] = this.treeAssessment;
        criteria['ntnl'] = this.ntnl;
        criteria['assessment'] = this.assessment;
        criteria['recentlyMapped'] = this.recentlyMapped;
        criteria['recentlyMappedDate'] = this.recentlyMappedDate;
    }

    setSearchCriteria(criteria) {
        if (criteria) {
            this.stocktake = criteria.stocktake;
            this.treeAssessment = criteria.treeAssessment;
            this.ntnl = criteria.ntnl;
            this.assessment = criteria.assessment;
            this.recentlyMapped = criteria.recentlyMapped;
            this.recentlyMappedDate = criteria.recentlyMappedDate;
        }
    }

    setRecentlyMappedDate(dateString) {
        if (this.plantdataService.jsonData.criteria) {
            this.recentlyMappedDate = new Date(dateString);
            this.getSearchCriteria(this.plantdataService.jsonData.criteria);
            this.showRecentlyMapped();
        }
    }

    showRecentlyMapped() {
        if (this.plantdataService.jsonData.criteria) {
            this.getSearchCriteria(this.plantdataService.jsonData.criteria);
            this.triggerService.redraw.emit(false);
        }
    }
}
