mport ballerina/graphql;
import ballerina/io;
import ballerina/http;

public type Department record {
    string id;
    string name;
}

public type KPI record {
    string id;
    string name;
}

public type Objective record {
    string id;
    string name;
}

public type PerformanceRecord record {
    string id;
    string userId;
    string kpiId;
    string objectiveId;
    float score;
}

public type User record {
    string id;
    string firstName;
    string lastName;
}

mongoDB:ConnectionConfig mongoConfig = {
    connection: {
        host: "localhost",
        port: 27017,
        auth: {
            username: "username",
            password: "password",
        },
        options: {
            ssLEnabled: false,
            serverSelectionTimeout: 5000
        }
    },
    databaseName: "performance_management"
};

mongodb:Client db = new (mongoConfig);

configurable string H;

service /graphql on new graphql:Listener(4000) {
    remote function getUsers() returns User[] {
        var result = check db->find("users", {});
        User[] users = [];
        while (result.hasNext()) {
            var user = result.next();
            users.push(<User> user);
        }
        return users;
    }

    remote function addPerformanceRecord(PerformanceRecord newRecord) returns string {
        map<json> doc = <map<json>> newRecord;
        _ = check db->insert("performance_records", doc);
        return "Performance record added successfully";
    }

    remote function getDepartments() returns Department[] {
        var result = check db->find("departments", {});
        Department[] departments = [];
        while (result.hasNext()) {
            var department = result.next();
            departments.push(<Department> department);
        }
        return departments;
    }
}