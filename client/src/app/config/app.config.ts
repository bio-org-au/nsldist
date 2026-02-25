import {Injectable} from '@angular/core';
import {HttpClient} from "@angular/common/http";

@Injectable()
export class AppConfig {

    private config: Object = null;
    private env: Object = null;
    constructor(private http: HttpClient) {
    }

    /**
     * Use to get the data found in the second file (config file)
     */
    public getConfig(key: any) {
        return this.config[key];
    }

    /**
     * Use to get the data found in the first file (env file)
     */
    public getEnv(key: any) {
        return this.env[key];
    }

    /**
     * This method:
     *   a) Loads "env.json" to get the current working environment (e.g.: 'production', 'development')
     *   b) Loads "config.[env].json" to get all env's variables (e.g.: 'config.development.json')
     */
    public load(): Promise<boolean> {
        return new Promise((resolve) => {
            this.http.get('config/env.json').subscribe({
                next: (envResponse: any) => {
                    this.env = envResponse;
                    const envName = envResponse["env"];

                    console.log("load 1");
                    if (envName) {
                        console.log("load 2");
                        this.http.get(`config/env.${envName}.json`).subscribe({
                            next: (responseData: any) => {
                                this.config = responseData;
                                resolve(true);
                            },
                            error: () => {
                                console.error('Could not load config file');
                                resolve(true);
                            }
                        });
                        console.log("load 3");
                    } else {
                        console.log("load 4");
                        resolve(true);
                    }
                },
                error: () => {
                    console.error('Could not load env.json');
                    resolve(true);
                }
            });
        });
    }
}
