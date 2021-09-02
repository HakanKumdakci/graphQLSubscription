//
//  ViewController.swift
//  ExampleGraphQLSubscription
//
//  Created by Hakan Kumdakçı on 27.08.2021.
//

import UIKit
import RxSwift
import RxCocoa
import Apollo

class Network{
    static let shared = Network()
    var apollo = ApolloClient(url: URL(string: "http://localhost:4000/")!)
}



class ViewController: UIViewController {
        
    var disposeBag = DisposeBag()
    var items =  BehaviorSubject<[Trade]>(value: [Trade(name: "BTC", price: "0"), Trade(name: "ETH", price: "0"), Trade(name: "BNB", price: "0"), Trade(name: "DOGE", price: "0"), Trade(name: "ADA", price: "0"), Trade(name: "DOT", price: "0"), Trade(name: "BCH", price: "0"), Trade(name: "LTC", price: "0"), Trade(name: "BUSD", price: "0"), Trade(name: "MATIC", price: "0")])

    
    var tableView: UITableView! = {
        var table = UITableView(frame: .zero)
        table.backgroundColor = .red
        table.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        table.translatesAutoresizingMaskIntoConstraints = false
        return table
    }()
    
    var trades : [Trade] = []
    var tradesSubscriptions: [Cancellable?] = []
    var subscription: Cancellable?
    
    var connectionOfTrades: [Bool] = []
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        self.items
            .subscribe{
                self.trades = $0
            }
        
        view.addSubview(tableView)

        tableView.topAnchor.constraint(equalTo: view.readableContentGuide.topAnchor).isActive = true
        tableView.leadingAnchor.constraint(equalTo: view.readableContentGuide.leadingAnchor).isActive = true
        tableView.trailingAnchor.constraint(equalTo: view.readableContentGuide.trailingAnchor).isActive = true
        tableView.bottomAnchor.constraint(equalTo: view.readableContentGuide.bottomAnchor).isActive = true
        //self.tableView.bounds = CGRect(x: -280, y: 100, width: 600, height: 1400)
        
        bindTableData()
        
        for i in 1...trades.count{
            if (i>4){
                tradesSubscriptions.append(nil)
                connectionOfTrades.append(false)
                continue
            }
            connectionOfTrades.append(true)
            tradesSubscriptions.append(Apollo2.shared.client.subscribe(subscription: TrackCoinSubscription(ep: i)){ result in
                
                switch result{
                case .success(let m):
                    if let x = m.data?.bookTitleChanged?.resultMap{
                        self.trades[i-1].price = x["title"] as! String
                        self.items.onNext(self.trades)
                        
                        if self.tradesSubscriptions.count == self.trades.count{
                            let timer = Timer.scheduledTimer(timeInterval: 0.2, target: self, selector: #selector(self.resetCells), userInfo: nil, repeats: true)
                        }
                    }
                    
                case .failure(let m):
                    print(m)
                }
            })
        }
        
        
        
        
        
        
        
        

    }
    
    @objc func resetCells(){
        checkCells()
        checkConnectivity()
    }
    
    func stopWebSocketConnectionOfCell(id: Int){
        
        let row = id-1
        if (tradesSubscriptions[row] == nil){
            return
        }
        connectionOfTrades[row] = false
        self.tradesSubscriptions[row]!.cancel()
        self.tradesSubscriptions[row] = nil
        
    }
    
    func refreshWebSocketConnectionOfCell(id: Int){
        let row = id-1
        if (tradesSubscriptions[row] != nil){
            return
        }
        self.connectionOfTrades[row] = true
        self.tradesSubscriptions[row] = Apollo2.shared.client.subscribe(subscription: TrackCoinSubscription(ep: id)){ result in
            switch result{
            case .success(let m):
                if let x = m.data?.bookTitleChanged?.resultMap{
                    print(x["title"], self.trades[row])
                    self.trades[row].price = x["title"] as! String
                    self.items.onNext(self.trades)
                    
                    
                }
                
            case .failure(let m):
                print(m)
            }
        }
    }
    
    
    
    func bindTableData(){
            self.items.bind(to: tableView.rx.items){ [self](tv, row, item) -> UITableViewCell in
                let indexPath = IndexPath(row: row, section: 0)
                let cell = tv.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
                cell.textLabel?.text = "\(item.name) : \(item.price)$"
                cell.backgroundColor = .red
                
                

                if (connectionOfTrades[row] == true){
                    refreshWebSocketConnectionOfCell(id: row+1)
                    cell.backgroundColor = .green
                }else{
                    stopWebSocketConnectionOfCell(id: row+1)
                    cell.backgroundColor = .red
                }
                
                
                return cell
                
            }.disposed(by: disposeBag)
        
            tableView.rowHeight = 202
            
            tableView.rx.modelSelected(Trade.self).bind{ trade in
                print(trade.price)
            }.disposed(by: disposeBag)
        }
    
    func checkConnectivity(){
        for i in 0..<connectionOfTrades.count{
            let indexPath = IndexPath(row: i, section: 0)
            //stopWebSocketConnectionOfCell(id: i+1)
            
            if let cell = tableView.cellForRow(at: indexPath){
                if connectionOfTrades[i] == false{
                    stopWebSocketConnectionOfCell(id: i+1)
                    cell.backgroundColor = .red
                }else{
                    refreshWebSocketConnectionOfCell(id: i+1)
                    cell.backgroundColor = .green
                }
            }else{
                if let m = tradesSubscriptions[i]{
                    stopWebSocketConnectionOfCell(id: i+1)
                }
            }
            
        }
    }
    
    func checkCells(){
        let visiblePaths = tableView.indexPathsForVisibleRows?.filter ({
                let rect = tableView.rectForRow(at: $0)
                return tableView.bounds.contains(rect)
            }).reduce(into: Set<IndexPath>(), { result, indexPath in
                result.insert(indexPath)
            })
        for i in 0..<connectionOfTrades.count{
            connectionOfTrades[i] = false
        }
        if let visiblePaths = visiblePaths as? Set<IndexPath>{
            for i in visiblePaths{
                if (i.row-1 >= 0){
                    connectionOfTrades[i.row-1] = true
                }
                if (i.row+1 < trades.count){
                    connectionOfTrades[i.row+1] = true
                }
                connectionOfTrades[i.row] = true
            }
        }
    }

}

