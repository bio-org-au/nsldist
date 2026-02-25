import {Feature} from "geojson";

export type MapFeature = Feature & {
    checked: boolean;
    properties: {
        publicDisplayName: string;
        [key: string]: any; // Allows other standard properties
    };
    layer: L.Path & { feature: Feature }
};
